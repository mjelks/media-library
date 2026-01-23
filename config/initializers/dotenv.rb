# Load .env file from app directory for Docker volume mount compatibility
Dotenv.load(Rails.root.join("app", ".env"))
