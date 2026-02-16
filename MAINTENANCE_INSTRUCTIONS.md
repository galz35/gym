# Maintenance Instructions for GymPro

This document outlines how to maintain the GymPro application, configure production environment on Render, and set up cron jobs to keep the service active.

## 🚀 Deployment to Render (Backend)

1. **Connect GitHub**: Connect your GitHub repository (`galz35/gym`) to Render.
2. **Create Web Service**:
   - **Root Directory**: `backend`
   - **Build Command**: `npm install && npx prisma generate && npm run build`
   - **Start Command**: `npx prisma db push && npm run start:prod`
     - *Note: `prisma db push` synchronizes the database schema directly without migration files. Use this for rapid development/prototyping.*

3. **Environment Variables**:
   Add the following variables in Render Dashboard:
   - `DATABASE_URL`: (Your detailed PostgreSQL URL)
   - `JWT_SECRET`: (Your secret)
   - `JWT_EXPIRES_IN`: `7d`
   - `supbase_url`: (If needed)
   - `supabase_key`: (If needed)

## 💓 Keep-Alive (Cron Job)

To prevent the free Render instance from sleeping (spinning down after inactivity), use **cron-job.org**.

### Steps:
1. **Endpoint**: We created a lightweight endpoint: `GET /health/ping`.
   - It queries the database (table `sistema_status`) to ensure the DB connection is active and creates a record if missing.
   - It returns `{ status: 'ok', system: ... }`.

2. **Cron Job Setup**:
   - Go to [cron-job.org](https://console.cron-job.org/dashboard).
   - Sign up / Log in.
   - Click **"Create Cronjob"**.
   - **Title**: `GymPro Health Check`
   - **URL**: `https://<YOUR-RENDER-APP-NAME>.onrender.com/health/ping`
   - **Execution Schedule**: Every **10 minutes**.
   - **Notifications**: Optional (disable "Execution failed" unless critical).
   - **Save**.

This will ping your backend every 10 minutes, keeping the Render instance active and the database connection warm.

## 📱 Mobile App (APK Release)

The APK has been generated in `flutter/build/app/outputs/flutter-apk/app-release.apk`.
You can distribute this file to Android users.

## 🛠 Troubleshooting

- **Database Connection**: If `prisma generate` fails locally, ensure your `DATABASE_URL` is correct. The production build on Render runs on Linux and should handle the connection string correctly.
- **CORS**: CORS is enabled for all origins (`*`) by default in `main.ts` for ease of access. For better security later, restrict `origin` in `app.enableCors()`.
