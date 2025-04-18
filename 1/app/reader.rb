services:
  db:
    image: postgres
  restart: always
  env_file: - .env
  environment:
    PGDATA: /var/lib/postgresql/data
  PGUSER: postgres
  PGDATABASE: postgres
  PGPASSWORD: postgres
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U postgres -d postgres"]
  interval: 10s
retries: 5
start_period: 30s
timeout: 10s
volumes:
  - db-data:/var/lib/postgresql/data
ports:
  - "5432:5432"

volumes:
  db-data: {}
