import requests
import os
from typing import List, Optional
from . import schemas
from app.core.config import settings

ALFRESCO_API_BASE = settings.ALFRESCO_API_BASE

FAQ_AUTH_URL = settings.FAQ_AUTH_URL
FAQ_URL = settings.FAQ_URL
FAQ_CLIENT_ID = settings.FAQ_CLIENT_ID
FAQ_CLIENT_SECRET = settings.FAQ_CLIENT_SECRET


class FAQService:
    def __init__(self):
        self.auth_url = FAQ_AUTH_URL
        self.faq_url = FAQ_URL
        self.client_id = FAQ_CLIENT_ID
        self.client_secret = FAQ_CLIENT_SECRET

    def get_auth_token(self) -> Optional[str]:
        """Get authentication token from the API"""
        try:
            response = requests.post(
                self.auth_url,
                data={
                    'grant_type': 'client_credentials',
                    'scope': 'profile api'
                },
                auth=(self.client_id, self.client_secret)
            )
            response.raise_for_status()
            token_data = response.json()
            return token_data.get('access_token')
        except requests.exceptions.RequestException as e:
            print(f"Error getting auth token: {e}")
            return None

    def get_all_faqs(self) -> List[schemas.FAQItem]:
        """Get all FAQs from the API"""
        token = self.get_auth_token()
        if not token:
            return []

        try:
            headers = {
                'accept': 'application/json, text/plain, */*',
                'accept-language': 'en',
                'authorization': f'Bearer {token}',
                'sec-fetch-mode': 'cors',
                'sec-fetch-site': 'same-origin'
            }

            params = {
                'query': '',
                'deleted': 0,
                'limit': 100,
                'incTotal': 'false',
                'incPageNavigation': 'false',
                'sort': ''
            }

            response = requests.get(
                self.faq_url,
                headers=headers,
                params=params
            )
            response.raise_for_status()

            data = response.json()
            faq_items = []

            for item in data.get('response', {}).get('set', []):
                # Extract values from the nested structure
                values_dict = {}
                for value in item.get('values', []):
                    values_dict[value['name']] = value['value']

                faq_item = schemas.FAQItem(
                    recordID=item['recordID'],
                    question=values_dict.get('question', ''),
                    answer=values_dict.get('answer', ''),
                    category=values_dict.get('category', ''),
                    subcategory=values_dict.get('subcategory', '')
                )
                faq_items.append(faq_item)

            return faq_items

        except requests.exceptions.RequestException as e:
            print(f"Error fetching FAQs: {e}")
            return []

    def get_filtered_faqs(self, user_type: Optional[str] = None) -> List[schemas.FAQItem]:
        """Get FAQs filtered by user type (category)"""
        all_faqs = self.get_all_faqs()

        if not user_type:
            return all_faqs

        # Filter by category (user_type)
        filtered_faqs = [
            faq for faq in all_faqs
            if faq.category.lower() == user_type.lower()
        ]

        return filtered_faqs