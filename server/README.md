#  VantanceCA Orchestration – FastAPI + Keycloak (Oracle Ready)

This project is a production-level FastAPI application built with modular structure and integrates Keycloak for authentication.

---

##  Folder Structure

```
app/
├── api/                    # Global router entry point
├── common/                 # Shared CRUD and schemas
├── core/                  # Config, DB, context manager, logger
├── modules/
│   ├── users/             # Feature module for user handling
│   └── keycloak/          # Keycloak integration services
├── main.py                # FastAPI app entry
docker/
├── Dockerfile
└── docker-compose.yml
.env
requirements.txt
```

---

##  Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/abduldev-cloud/VantanceCA.git
cd server
```

### 2. Create a virtual environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

---

## ⚙️ Environment Variables

Create a `.env` file in the root:

```env
KEYCLOAK_BASE_URL=https://your-keycloak.com
KEYCLOAK_REALM=your-realm
KEYCLOAK_CLIENT_ID=admin-cli
KEYCLOAK_CLIENT_SECRET=your-client-secret
```

---

## 🧪 Run the application (local)

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

---

## 🐳 Run with Docker

```bash
cd docker
docker-compose up --build
```

---

## ✅ Available Endpoints

| Method | Path          | Description               |
| ------ | ------------- | ------------------------- |
| GET    | /             | Home route                |
| GET    | /users/health | Health check              |
| POST   | /users/       | Create a user in Keycloak |
| POST   | /users/login  | Login a user in Keycloak  |

---

## 🧰 Tech Stack

- **FastAPI** – Web framework
- **Keycloak** – Identity provider
- **Pydantic** – Data validation
- **httpx** – Async HTTP client
- **Docker** – Containerization

---

## 📦 Production Features

- Modular app structure
- Keycloak integration
- Exception handling
- Async services with httpx
- Reusable context manager
- Environment-driven configuration
