# Mediscribe Backend

Node.js API server for auth and user data.

## Setup

1. Copy `.env.example` to `.env`
2. Update `MONGO_URI` and `JWT_SECRET`
3. Install and run:

```bash
npm install
npm run dev
```

## Endpoints

- `GET /health`
- `POST /api/auth/signup`
- `POST /api/auth/login`

Example signup body:

```json
{
  "name": "Aman Verma",
  "email": "aman@gmail.com",
  "password": "secret123"
}
```
