
import asyncio
from app.common.auth.verify_google_token import verify_google_id_token
import httpx
from fastapi import HTTPException
from app.modules.classes.schemas import CreateKeycloakGroupSchema
from app.modules.users.schemas import CreateUserInviteSchema, CreateKeycloakUserSchema, UpdateUserSchema
from app.core.config import settings


class KeycloakService:
    def __init__(self):
        self.base_url = settings.KEYCLOAK_BASE_URL
        self.realm = settings.KEYCLOAK_REALM
        self.client_id = settings.KEYCLOAK_CLIENT_ID
        self.client_secret = settings.KEYCLOAK_CLIENT_SECRET
        self.subject_issuer = settings.KEYCLOAK_OAUTH_SUBJECT_ISSUER
        self.scope = settings.KEYCLOAK_OAUTH_SCOPE
        self.platform_admin_client_id = settings.KEYCLOAK_PLATFORM_ADMIN_CLIENT_ID
        self.platform_admin_client_secret = settings.KEYCLOAK_PLATFORM_ADMIN_CLIENT_SECRET

    async def get_admin_token(self, isPlatformAdmin: bool = False) -> str:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/realms/{self.realm}/protocol/openid-connect/token",
                data={
                    "grant_type": "client_credentials",
                    "client_id": self.platform_admin_client_id if isPlatformAdmin else self.client_id,
                    "client_secret": self.platform_admin_client_secret if isPlatformAdmin else self.client_secret,
                },
                headers={"Content-Type": "application/x-www-form-urlencoded"},
            )
        if response.status_code != 200:
            raise HTTPException(status_code=500, detail="Keycloak token error")
        return response.json()["access_token"]

    async def invite_user(self, schema: CreateUserInviteSchema) -> str:
        token = await self.get_admin_token()
        email, role = schema.email, schema.role
        async with httpx.AsyncClient() as client:
            user_response = await client.post(
                f"{self.base_url}/admin/realms/{self.realm}/users",
                json={
                    "username": email,
                    "email": email,
                    "enabled": False,  # User is not enabled until they accept the invite
                },
                headers={"Authorization": f"Bearer {token}"},
            )

        if user_response.status_code == 409:
            raise HTTPException(status_code=409, detail="User already exists in Keycloak")
        if user_response.status_code != 201:
            raise HTTPException(status_code=500, detail="Failed to create invited user")

        location = user_response.headers.get("location")
        user_id = location.split("/")[-1] if location else None
        if not user_id:
            raise HTTPException(status_code=500, detail="User ID retrieval failed")

        # Assign role
        async with httpx.AsyncClient() as client:
            role_resp = await client.get(
                f"{self.base_url}/admin/realms/{self.realm}/roles/{role}",
                headers={"Authorization": f"Bearer {token}"},
            )
            if role_resp.status_code != 200:
                raise HTTPException(status_code=404, detail="Role not found")

            assign_resp = await client.post(
                f"{self.base_url}/admin/realms/{self.realm}/users/{user_id}/role-mappings/realm",
                json=[role_resp.json()],
                headers={"Authorization": f"Bearer {token}"},
            )
            if assign_resp.status_code not in (204, 201):
                raise HTTPException(status_code=500, detail="Role assignment failed")

        return user_id
    
    async def update_user_details(self, user_id: str, schema: UpdateUserSchema) -> None:
        token = await self.get_admin_token()
        # Update basic info
        async with httpx.AsyncClient() as client:
            update_data = {
                "firstName": schema.first_name,
                "lastName": schema.last_name,
                "email": schema.email,
                "enabled": True,
            }
            if schema.phone_number:
                update_data["attributes"] = {"phone_number": [schema.phone_number]}

            update_resp = await client.put(
                f"{self.base_url}/admin/realms/{self.realm}/users/{user_id}",
                json=update_data,
                headers={"Authorization": f"Bearer {token}"},
            )
            if update_resp.status_code != 204:
                raise HTTPException(status_code=500, detail="Failed to update user details")
        # Update password
        if schema.password is not None:
            await self.reset_user_password(user_id, schema.password)
            
    async def update_user_with_google(self, user_id: str, google_token: str) -> str:
        user_info = verify_google_id_token(google_token)
        if not user_info:
            raise HTTPException(status_code=401, detail="Invalid Google token")
        #transform user_info to UpdateUserSchema
        update_schema = UpdateUserSchema(
            first_name=user_info.get("firstname"),
            last_name=user_info.get("lastname"),
            email=user_info.get("email"),
            phone_number=None,  
            password=None 
        )
        await self.update_user_details(user_id, update_schema)
        
    # async def update_user_with_google(self, user_id: str, google_token: str) -> None:
    #     token = await self.get_admin_token()
    #     async with httpx.AsyncClient() as client:
    #         response = await client.post(
    #             f"{self.base_url}/admin/realms/{self.realm}/users/{user_id}/federated-identity/google",
    #             json={"token": google_token},
    #             headers={"Authorization": f"Bearer {token}"},
    #         )
    #     if response.status_code != 204:
    #         raise HTTPException(status_code=500, detail="Failed to update user with Google token")

    async def reset_user_password(self, user_id: str, password: str) -> None:
        token = await self.get_admin_token()
        async with httpx.AsyncClient() as client:
            password_resp = await client.put(
                f"{self.base_url}/admin/realms/{self.realm}/users/{user_id}/reset-password",
                json={
                    "type": "password",
                    "value": password,
                    "temporary": False,
                },
                headers={"Authorization": f"Bearer {token}"},
            )
            if password_resp.status_code != 204:
                raise HTTPException(status_code=500, detail="Failed to set user password")
            
    async def create_user(self, schema: CreateKeycloakUserSchema) -> str:
        token = await self.get_admin_token()
        async with httpx.AsyncClient() as client:
            user_response = await client.post(
                f"{self.base_url}/admin/realms/{self.realm}/users",
                json={
                    "username": schema.username,
                    "email": schema.email,
                    "firstName": schema.first_name,
                    "lastName": schema.last_name,
                    "enabled": True,
                    "attributes": {
                        "phone_number": [schema.phone_number],
                    },
                    "credentials": [
                        {
                            "type": "password",
                            "value": schema.password,
                            "temporary": False,
                        }
                    ],
                },
                headers={"Authorization": f"Bearer {token}"},
            )
        if user_response.status_code == 409:
            raise HTTPException(status_code=409, detail="User already exists in Keycloak")
        if user_response.status_code != 201:
            raise HTTPException(status_code=500, detail="Failed to create user")
        location = user_response.headers.get("location")
        user_id = location.split("/")[-1] if location else None
        if not user_id:
            raise HTTPException(status_code=500, detail="User ID retrieval failed")

        # Role assignment
        try:
            async with httpx.AsyncClient() as client:
                role_resp = await client.get(
                    f"{self.base_url}/admin/realms/{self.realm}/roles/{schema.role}",
                    headers={"Authorization": f"Bearer {token}"},
                )
                if role_resp.status_code != 200:
                    raise HTTPException(status_code=404, detail="Role not found in Keycloak")
                assign_resp = await client.post(
                    f"{self.base_url}/admin/realms/{self.realm}/users/{user_id}/role-mappings/realm",
                    json=[role_resp.json()],
                    headers={"Authorization": f"Bearer {token}"},
                )
                if assign_resp.status_code not in (204, 201):
                    raise HTTPException(status_code=500, detail="Failed to assign role to user")
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Role assignment failed: {str(e)}")

        return user_id

    async def login_user(self, username: str, password: str) -> dict:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/realms/{self.realm}/protocol/openid-connect/token",
                data={
                    "grant_type": "password",
                    "client_id": self.client_id,
                    "client_secret": self.client_secret,
                    "username": username,
                    "password": password,
                },
                headers={"Content-Type": "application/x-www-form-urlencoded"},
            )
        if response.status_code != 200:
            raise HTTPException(status_code=500, detail="Keycloak login failed")
        return {
            "access_token": response.json()["access_token"],
            "refresh_token": response.json()["refresh_token"],
        }
        
    async def refresh_token(self, refresh_token: str) -> dict:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/realms/{self.realm}/protocol/openid-connect/token",
                data={
                    "grant_type": "refresh_token",
                    "client_id": self.client_id,
                    "client_secret": self.client_secret,
                    "refresh_token": refresh_token,
                },
                headers={"Content-Type": "application/x-www-form-urlencoded"},
            )
        if response.status_code != 200:
            raise HTTPException(status_code=500, detail="Keycloak token refresh failed")
        return response.json()
    
    async def login_user_with_google(self, token: str) -> dict:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/realms/{self.realm}/protocol/openid-connect/token",
                data={
                    "client_id": self.client_id,
                    "client_secret": self.client_secret,
                    "subject_issuer":self.subject_issuer,
                    "scope": self.scope,
                    "subject_token": token,
                },
                headers={"Content-Type": "application/x-www-form-urlencoded"},
            )
        if response.status_code != 200:
            raise HTTPException(status_code=500, detail="Keycloak Google login failed")
        return response.json()
    
    async def logout_user(self, refresh_token: str) -> None:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/realms/{self.realm}/protocol/openid-connect/logout",
                data={
                    "client_id": self.client_id,
                    "client_secret": self.client_secret,
                    "refresh_token": refresh_token,
                },
                headers={"Content-Type": "application/x-www-form-urlencoded"},
            )
        if response.status_code != 204:
            raise HTTPException(status_code=500, detail="Keycloak logout failed")
    
    async def create_group(self, schema: CreateKeycloakGroupSchema) -> None:
        token = await self.get_admin_token()
        grade_str = (schema.grade_name or "").replace(" ", "")
        class_str = (schema.class_name or "").replace(" ", "")

        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/admin/realms/{self.realm}/groups",
                json={
                    "name": f"{schema.institute_id}-{grade_str}-{schema.class_id}-{class_str}",
                    "attributes": {
                        "grade": [grade_str],
                        "className": [class_str],
                        "classId": [schema.class_id],
                        "instituteId": [schema.institute_id],
                        "status": ["inactive"]
                    }
                },
                headers={"Authorization": f"Bearer {token}"},
            )

        if response.status_code == 409:
            raise HTTPException(status_code=409, detail="Group already exists in Keycloak")
        if response.status_code != 201:
            raise HTTPException(status_code=500, detail="Failed to create group")
    
    #get keycloak group by name
    async def get_group_by_name(self, group_name: str) -> dict:
        token = await self.get_admin_token()
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{self.base_url}/admin/realms/{self.realm}/groups",
                params={"search": group_name},
                headers={"Authorization": f"Bearer {token}"},
            )
        if response.status_code != 200:
            raise HTTPException(status_code=500, detail="Failed to fetch group")
        groups = response.json()
        if not groups:
            raise HTTPException(status_code=404, detail="Group not found")
        return groups[0].get("id", None) 
    
    
    # add user to keycloak group
    async def add_user_to_group(self, user_id: str, group_name: str) -> None:
        token = await self.get_admin_token()
        group_id = await self.get_group_by_name(group_name)
        async with httpx.AsyncClient() as client:
            response = await client.put(
                f"{self.base_url}/admin/realms/{self.realm}/users/{user_id}/groups/{group_id}",
                headers={"Authorization": f"Bearer {token}"},
            )
        if response.status_code != 204:
            raise HTTPException(status_code=500, detail="Failed to add user to group")

    async def add_user_to_groups(self, user_id: str, group_names: list[str]) -> None:
        token = await self.get_admin_token()

        async with httpx.AsyncClient() as client:
            # Fetch all groups once
            resp = await client.get(
                f"{self.base_url}/admin/realms/{self.realm}/groups",
                headers={"Authorization": f"Bearer {token}"},
            )
            if resp.status_code != 200:
                raise HTTPException(status_code=500, detail="Failed to fetch groups list")
            
            # Prepare all PUT requests
            tasks = []
            for name in group_names:
                group_id = await self.get_group_by_name(name)
                if not group_id:
                    raise HTTPException(status_code=404, detail=f"Group '{name}' not found")

                tasks.append(
                    client.put(
                        f"{self.base_url}/admin/realms/{self.realm}/users/{user_id}/groups/{group_id}",
                        headers={"Authorization": f"Bearer {token}"},
                    )
                )

            # Run all requests in parallel
            results = await asyncio.gather(*tasks)

            # Check for failures
            for name, res in zip(group_names, results):
                if res.status_code != 204:
                    raise HTTPException(
                        status_code=res.status_code,
                        detail=f"Failed to add user to group '{name}': {res.text}"
                    )

        
    async def create_client(self, client_id: str) -> None:
        token = await self.get_admin_token()
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/admin/realms/{self.realm}/clients",
                json={
                    "clientId": client_id,
                    "name": f"Client for {client_id}",  
                    "enabled": True,
                    "protocol": "openid-connect",
                    "publicClient": False,
                    "secret": self.client_secret,
                    "serviceAccountsEnabled": True,
                    "standardFlowEnabled": False,
                    "directAccessGrantsEnabled": False
                },
                headers={"Authorization": f"Bearer {token}"},
            )
        if response.status_code != 201:
            raise HTTPException(status_code=500, detail="Failed to create client")
     
    async def get_user_id_by_username(self, username: str) -> str:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{self.base_url}/admin/realms/{self.realm}/users",
                params={"username": username},
                headers={
                    "Authorization": f"Bearer {await self.get_admin_token()}",
                },
            )
        if response.status_code != 200 or not response.json():
            raise HTTPException(status_code=404, detail="User not found")
        return response.json()[0]["id"]  
        
    async def impersonate_token(self, username: str) -> dict:
        user_id = await self.get_user_id_by_username(username)
        if not user_id:
            raise HTTPException(status_code=404, detail="User not found")
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/realms/{self.realm}/protocol/openid-connect/token",
                data={
                    "client_id": self.platform_admin_client_id,
                    "client_secret": self.platform_admin_client_secret,
                    "grant_type": "urn:ietf:params:oauth:grant-type:token-exchange",
                    "requested_subject": user_id,
                },
            )
        if response.status_code != 200:
            raise HTTPException(status_code=500, detail="Token exchange failed")
        return response.json()

    async def get_user_details(self, user_id: str) -> dict:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{self.base_url}/admin/realms/{self.realm}/users/{user_id}",
                headers={"Authorization": f"Bearer {await self.get_admin_token()}"}
            )
        if response.status_code != 200:
            raise HTTPException(status_code=404, detail="User not found")
        user_details = response.json()
        return {
            "id": user_details.get("id"),
            "username": user_details.get("username"),
            "email": user_details.get("email"),
            "enabled": user_details.get("enabled")
        }
        
    async def is_user_enabled(self, user_id: str) -> bool:
        try:
            user_details = await self.get_user_details(user_id)
            return user_details.get("enabled", False)
        except HTTPException as e:
            if e.status_code == 404:
                raise HTTPException(status_code=404, detail="User not found")
            raise HTTPException(status_code=500, detail="Failed to fetch user status")

    async def update_user_status(self, user_ids: list[str], status: bool = False) -> None:
        token = await self.get_admin_token()
        async with httpx.AsyncClient() as client:
            tasks = []
            enabled_user_ids = []
            for user_id in user_ids:
                # Check if the user is already disabled
                try:
                    user_det = await self.get_user_details(user_id)
                except HTTPException as e:
                    continue
                if user_det.get("enabled", False) == status:
                    continue
                enabled_user_ids.append(user_id)
                user_det["enabled"] = status
                tasks.append(
                    client.put(
                        f"{self.base_url}/admin/realms/{self.realm}/users/{user_id}",
                        json=user_det,
                        headers={"Authorization": f"Bearer {token}"},
                    )
                )

            if not tasks:
                return 
            
            # Run all update group requests in parallel
            results = await asyncio.gather(*tasks)

            # Check for failures
            for name, res in zip(enabled_user_ids, results):
                if res.status_code != 204:
                    raise HTTPException(
                        status_code=res.status_code,
                        detail=f"Failed to disable user '{name}': {res.text}"
                    )
            
    async def update_groups_status(self, group_names: list[str], status="archived") -> None:
        token = await self.get_admin_token()

        async with httpx.AsyncClient() as client:
            tasks = []
            updated_group_names = []

            for name in group_names:
                group_id = await self.get_group_by_name(name)
                attr_resp = await client.get(
                    f"{self.base_url}/admin/realms/{self.realm}/groups/{group_id}",
                    headers={"Authorization": f"Bearer {token}"},
                )
                if attr_resp.status_code != 200:
                    raise HTTPException(status_code=500, detail=f"Failed to fetch attributes for group '{name}'")

                group_data = attr_resp.json()
                existing_attrs = group_data.get("attributes", {})

                # Skip update if status is already correct
                current_status = existing_attrs.get("status", [None])[0]
                if current_status == status:
                    continue

                # Update the status to archived
                existing_attrs["status"] = [status]
                updated_group_names.append(name)
                tasks.append(
                    client.put(
                        f"{self.base_url}/admin/realms/{self.realm}/groups/{group_id}",
                        json={
                            "name": group_data.get('name'),
                            "attributes": existing_attrs
                        },
                        headers={"Authorization": f"Bearer {token}"},
                    )
                )

            if not tasks:
                return

            # Run all update group requests in parallel
            results = await asyncio.gather(*tasks)

            # Check for failures
            for name, res in zip(updated_group_names, results):
                if res.status_code != 204:
                    raise HTTPException(
                        status_code=res.status_code,
                        detail=f"Failed to archive group '{name}': {res.text}"
                    )
                
    async def remove_user_from_groups(self, user_id: str, group_names: list[str]) -> None:
        token = await self.get_admin_token()
        
        async with httpx.AsyncClient() as client:
            tasks = []
            for name in group_names:
                group_id = await self.get_group_by_name(name)
                tasks.append(
                    client.delete(
                        f"{self.base_url}/admin/realms/{self.realm}/users/{user_id}/groups/{group_id}",
                        headers={"Authorization": f"Bearer {token}"},
                    )
                )
            
            if not tasks:
                return
            
            # Run all requests in parallel
            results = await asyncio.gather(*tasks)
            
            # Check for failures
            for name, res in zip(group_names, results):
                if res.status_code != 204:
                    raise HTTPException(
                        status_code=res.status_code,
                        detail=f"Failed to remove user from group '{name}': {res.text}"
                    )