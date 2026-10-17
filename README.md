# 🚀 Maverick Viper — NPTEL MCQ Preparation Platform

Maverick Viper is an interactive, gamified assessment and learning platform built for NPTEL's "Foundation of Digital Business" course.

## ✨ Features
- **Student Dashboard**: Performance stats, donut accuracy charts, test attempts history.
- **Read MCQs Mode**: Week-wise study with instant correct answer highlights.
- **Exam Engine**: 3 test modes (All MCQs, Week-Wise, Shuffle) with mandatory instant green/red answer feedback and question navigation.
- **Admin Control Center**: Dynamic week management, single/bulk MCQ upload (Word `.docx`, Excel, CSV, Text), student login activity tracker.

## 🛠️ Tech Stack
- **Backend**: Jakarta Servlet 6.0, Jakarta EE 10, Java 21
- **Server**: Apache Tomcat 10.1 (Docker Container) / GlassFish 7
- **Database**: MySQL 8.0 (with self-healing auto-schema creation)
- **Deployment**: Render / Railway (Dockerized)

## 🚀 Quick Cloud Deployment (Render + Free MySQL)
1. Push this repository to your GitHub account.
2. Create a free MySQL 8 database on [TiDB Cloud](https://tidbcloud.com) or [Railway](https://railway.app).
3. Connect your GitHub repository to [Render.com](https://render.com) as a **Web Service (Docker runtime, Free plan)**.
4. Add the `MYSQL_URL` environment variable with your database connection string.
5. The application boots up, automatically sets up tables, seeds Weeks 0-12, and is ready for use!
