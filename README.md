# Vantance CA - Exam Preparation Platform

An advanced educational platform built to facilitate interactions between schools, teachers, and learners. The platform supports assigning tasks, grading, AI-assisted study material processing, and comprehensive mock examination workflows.

## 🚀 Tech Stack

### Frontend (`webapp/`)
- **Framework**: React.js
- **Styling**: Vanilla CSS / CSS Modules
- **Routing**: React Router
- **Development Server**: Vite / Create React App

### Backend (`server/`)
- **Framework**: FastAPI (Python)
- **Database**: MySQL / Oracle (with SQLAlchemy)
- **Authentication**: Keycloak (with a local Mock Auth environment for development)
- **AI Integration**: OpenRouter / Local LLM (Ollama)
- **Serverless/Runtime**: Uvicorn

---

## 🛠️ Local Development Setup

### 1. Database Setup
1. Create a MySQL database (e.g., `ca_exam`).
2. Import the latest clean SQL dump to initialize the required tables:
   ```bash
   mysql -u root -p ca_exam < clean_dump.sql
   ```

### 2. Backend Setup
1. Navigate to the server directory:
   ```bash
   cd server
   ```
2. Set up a virtual environment and install dependencies:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```
3. Configure your `.env` file based on `.env.example` with your local database credentials (e.g., `MYSQL_USER`, `MYSQL_PASSWORD`, etc.).
4. Run the FastAPI development server:
   ```bash
   python -m uvicorn app.main:app --reload --port 8000
   ```

### 3. Frontend Setup
1. Navigate to the webapp directory:
   ```bash
   cd webapp
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Run the development server:
   ```bash
   npm run dev
   ```

---

## 📁 Project Structure

```text
ca_exam_preparation/
├── server/               # FastAPI Backend codebase
│   ├── app/
│   │   ├── core/         # Settings, database config
│   │   ├── modules/      # Domain modules (users, teachers, learners, ai)
│   │   └── main.py       # FastAPI application entry point
│   └── .env              # Backend environment variables
├── webapp/               # React Frontend codebase
│   ├── src/
│   │   ├── components/   # Reusable UI components
│   │   └── pages/        # Route pages (auth, student, teacher)
│   └── package.json
├── clean_dump.sql        # Database schema and mock data
└── README.md             # Project documentation
```

## 🔒 Authentication (Local Dev)
The application normally integrates with Keycloak for authentication. For isolated local development, the system falls back to an **Auth Mock** service (`/modules/auth_mock/`) which queries directly against the `mock_users` and `BINARY_SUCCESS_PLATFORM_USERS` tables using JWT.

## 🤝 Contributing
1. Ensure all new components follow the existing design aesthetics.
2. Verify that any database schema changes are added to the foundational dumps.
3. Keep the `.env` clear of hardcoded sensitive secrets in version control.
