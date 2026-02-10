# core/config.py
import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    APP_ENV: str = os.getenv("APP_ENV", "development")
    APP_PORT: int = int(os.getenv("APP_PORT", 8000))
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    NOTIFICATION_SERVICE_URL: str = os.getenv("NOTIFICATION_SERVICE_URL", "http://localhost:8000/notification")

    ORACLE_USER: str = os.getenv("ORACLE_USER")
    ORACLE_PASSWORD: str = os.getenv("ORACLE_PASSWORD")
    ORACLE_DSN: str = os.getenv("ORACLE_DSN")
    ORACLE_DB_URL: str = os.getenv("ORACLE_DB_URL")
    ORACLE_WALLET_PATH: str = os.getenv("ORACLE_WALLET_PATH")
    ORACLE_DB_FIACON_URL: str = os.getenv("ORACLE_DB_FIACON_URL")
    
    # MySQL configuration (for local development)
    MYSQL_HOST: str = os.getenv("MYSQL_HOST", "localhost")
    MYSQL_PORT: int = int(os.getenv("MYSQL_PORT", 3306))
    MYSQL_DATABASE: str = os.getenv("MYSQL_DATABASE", "binary_success")
    MYSQL_USER: str = os.getenv("MYSQL_USER", "bsadmin")
    MYSQL_PASSWORD: str = os.getenv("MYSQL_PASSWORD", "BsAdmin123")
    # Keycloak configuration
    KEYCLOAK_BASE_URL: str = os.getenv("KEYCLOAK_BASE_URL")
    KEYCLOAK_CLIENT_ID: str = os.getenv("KEYCLOAK_CLIENT_ID")
    KEYCLOAK_CLIENT_SECRET: str = os.getenv("KEYCLOAK_CLIENT_SECRET")
    KEYCLOAK_REALM: str = os.getenv("KEYCLOAK_REALM")
    KEYCLOAK_OAUTH_SCOPE: str = os.getenv("KEYCLOAK_OAUTH_SCOPE")
    KEYCLOAK_OAUTH_SUBJECT_ISSUER: str = os.getenv("KEYCLOAK_OAUTH_SUBJECT_ISSUER")
    KEYCLOAK_PLATFORM_ADMIN_CLIENT_ID: str = os.getenv("KEYCLOAK_PLATFORM_ADMIN_CLIENT_ID")
    KEYCLOAK_PLATFORM_ADMIN_CLIENT_SECRET: str = os.getenv("KEYCLOAK_PLATFORM_ADMIN_CLIENT_SECRET")
    
    #elasticsearch configuration
    ELASTICSEARCH_URL: str = os.getenv("ELASTICSEARCH_URL", "http://localhost:9200")
    ELASTICSEARCH_INDEX: str = os.getenv("ELASTICSEARCH_INDEX", "notifications")

    SMTP_SERVER: str = os.getenv("SMTP_SERVER")
    SMTP_PORT: int = int(os.getenv("SMTP_PORT", 465))
    SMTP_USERNAME: str = os.getenv("SMTP_USERNAME")
    SMTP_PASSWORD: str = os.getenv("SMTP_PASSWORD")

    LLM_API_URL: str = os.getenv("LLM_API_URL")
    LLM_API_TOKEN: str = os.getenv("LLM_API_TOKEN")

    KILLBILL_BASE_URL: str = os.getenv("KILLBILL_BASE_URL")
    KILLBILL_API_KEY: str = os.getenv("KILLBILL_API_KEY")
    KILLBILL_API_SECRET: str = os.getenv("KILLBILL_API_SECRET")
    KILLBILL_USERNAME: str = os.getenv("KILLBILL_USERNAME")
    KILLBILL_PASSWORD: str = os.getenv("KILLBILL_PASSWORD")
    KILLBILL_CREATED_BY: str = os.getenv("KILLBILL_CREATED_BY")
    KILLBILL_SCHOOL_BILLING_BASE_URL: str = os.getenv("KILLBILL_SCHOOL_BILLING_BASE_URL")
    KILLBILL_CUSTOMER_URL: str = os.getenv("KILLBILL_CUSTOMER_URL")
    KILLBILL_SESSIONS_URL: str = os.getenv("KILLBILL_SESSIONS_URL")

    BINARYSUCCESS_BASE_URL: str = os.getenv("BINARYSUCCESS_BASE_URL")
    GOOGLE_CLIENT_ID: str = os.getenv("GOOGLE_CLIENT_ID")
    GET_LEARNER_TASK_DETAILS_URL: str = os.getenv("GET_LEARNER_TASK_DETAILS_URL")

    STRIPE_SECRET_KEY: str = os.getenv("STRIPE_SECRET_KEY")

    ALFRESCO_API_BASE: str = os.getenv("ALFRESCO_API_BASE")
    API_BASE: str = os.getenv("API_BASE")
    ALFRESCO_WORKFLOW_BASE: str = os.getenv("ALFRESCO_WORKFLOW_BASE")
    ALFRESCO_USER: str = os.getenv("ALFRESCO_USER")
    ALFRESCO_PASS: str = os.getenv("ALFRESCO_PASS")

    # CRM
    CRM_BASE_URL: str = os.getenv("CRM_BASE_URL")
    CRM_NAMESPACE_ID: str = os.getenv("CRM_NAMESPACE_ID")
    CRM_CONTACT_MODULE_ID: str = os.getenv("CRM_CONTACT_MODULE_ID")
    CRM_SCHOOL_MODULE_ID: str = os.getenv("CRM_SCHOOL_MODULE_ID")
    CRM_TICKET_MODULE_ID: str = os.getenv("CRM_TICKET_MODULE_ID")

    # OAuth2
    CRM_CLIENT_ID: str = os.getenv("CRM_CLIENT_ID")
    CRM_CLIENT_SECRET: str = os.getenv("CRM_CLIENT_SECRET")
    CRM_TOKEN_URL: str = os.getenv("CRM_TOKEN_URL")

    # Defaults
    CRM_DEFAULT_OWNER: str = os.getenv("CRM_DEFAULT_OWNER")
    CRM_REPLY_MODULE_ID: str = os.getenv("CRM_REPLY_MODULE_ID")


    LLM_API_KEY: str = os.getenv("LLM_API_KEY")
    PROVIDER: str = os.getenv("PROVIDER")
    CHAT_MODEL: str = os.getenv("CHAT_MODEL")
    GET_LLM_API_URL: str = os.getenv("GET_LLM_API_URL")
    NOTIF_URL: str = os.getenv("NOTIF_URL")

    FAQ_AUTH_URL: str = os.getenv("FAQ_AUTH_URL")
    FAQ_URL: str = os.getenv("FAQ_URL")
    FAQ_CLIENT_ID: str = os.getenv("FAQ_CLIENT_ID")
    FAQ_CLIENT_SECRET: str = os.getenv("FAQ_CLIENT_SECRET")

settings = Settings()