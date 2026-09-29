# Centria — AI-Enabled Company Operating System

> **The Dual-Mode Enterprise Operating System:** Unifying people, workflows, documents, governance, analytics, operations, and finance onto a single intelligent platform.

[![Vercel Frontend](https://img.shields.io/badge/Frontend-Vercel-black?logo=vercel)](https://centria-enterprise.vercel.app/)
[![Render Backend](https://img.shields.io/badge/Backend-Render-46E3B7?logo=render)](https://centria-enterprise.onrender.com/)
[![Database](https://img.shields.io/badge/Neon_DB-PostgreSQL-00E599?logo=postgresql)](https://neon.tech/)
[![Storage](https://img.shields.io/badge/Neon_Object_Cloud-S3_Compatible-orange?logo=amazon-s3)](https://neon.tech/)
[![Transactional Email](https://img.shields.io/badge/Brevo-Transactional_Engine-0B99FF?logo=sendinblue)](https://brevo.com/)
[![AI Engine](https://img.shields.io/badge/Google_Gemini-Multimodal_AI-0EA5E9?logo=google)](https://deepmind.google/technologies/gemini/)

---

## 🌐 Live Deployments & Repository Links

* **Frontend (Vercel Web App)**: [https://centria-enterprise.vercel.app/](https://centria-enterprise.vercel.app/)
  * Public Home Page: `https://centria-enterprise.vercel.app/`
  * Privacy Policy: `https://centria-enterprise.vercel.app/privacy-policy`
  * Terms of Service: `https://centria-enterprise.vercel.app/terms-of-service`
* **Backend API (Render Web Service)**: [https://centria-enterprise.onrender.com/](https://centria-enterprise.onrender.com/)
  * Health Endpoint: `https://centria-enterprise.onrender.com/api/health/`
* **GitHub Repository**: [https://github.com/jasonkennethn/Centria.git](https://github.com/jasonkennethn/Centria.git)
* **Official Mail Sender**: `Centira <no-reply@celarox.com>`

---

## ⚡ Key Architectural Capabilities

### 1. Dual-Mode Operational Control
* **100% Manual Precision**: Direct manual CRUD control across employee directories, invoices, visual workflow definitions, policies, S3 documents, and custom schemas.
* **1-Click AI Acceleration**: Instant corporate genesis, multimodal contract extraction, morning executive summaries, and predictive delay-risk forecasting powered by **Google Gemini**.

### 2. 60-Second Company Genesis Wizard
* Founders answer 3 quick prompts $\rightarrow$ Gemini automatically generates:
  * Department organizational structures
  * Executive and operational roles with permission matrices
  * Mandatory HR policies & compliance baseline
  * Standard Chart of Accounts ledger

### 3. Multi-Platform Support
* Single unified Flutter codebase compiled for:
  * **Web** (Hosted on Vercel with responsive desktop & mobile support)
  * **Android APK** (`android/` release build with camera/storage permissions)
  * **iOS IPA** (`ios/` configuration ready)
  * **Desktop** (Linux / macOS / Windows)

### 4. Enterprise Infrastructure
* **Neon DB PostgreSQL**: Multi-tenant relational schemas with SSL channel-binding.
* **Neon Object Cloud (S3)**: Boto3 S3 integration storing all media, contracts, invoices, and documents.
* **Brevo API Engine**: Secure OTP authentication emails and workflow sign-off notifications sent from `Centira <no-reply@celarox.com>`.

---

## 📦 The 10 Unified Modules

| # | Module | Manual CRUD Control | Autonomous AI Acceleration |
|---|---|---|---|
| **1** | **Executive Cockpit** | Live cash balance, burn rate, headcount, pending approvals | 8:00 AM Morning Executive Brief & 1-click action cards |
| **2** | **60-Second Genesis** | Custom entity and branch setup | Automated department & chart of accounts synthesis |
| **3** | **People & HRMS** | Employee profiles, leave approval chains, attendance logs | AI onboarding task generator, job & offer letter drafting |
| **4** | **Workflow Engine** | Visual node-based trigger-condition-action rule builder | Human-in-the-loop 1-click executive approval queues |
| **5** | **Document Vault** | Secure Neon S3 upload, folder tags, version history | Gemini Multimodal OCR & plain-language contract summary |
| **6** | **Governance & Audit** | Policy manager, compliance calendar, immutable audit logs | Regulatory compliance auditor & tax deadline monitor |
| **7** | **Operations & Kanban** | Sprint planning, milestone tracking, Kanban boards | Gemini delay-risk predictor & velocity forecaster |
| **8** | **Finance & Invoicing** | Double-entry ledger, invoice issuance, expense tracker | 1-Click invoice dispatch via Brevo, runway analysis |
| **9** | **Predictive Analytics** | Department workload graphs, cash burn vs revenue | Neural bottleneck detector and burnout risk index |
| **10** | **AI Copilot & Omnibar** | Universal ⌘K search across all entities & quick commands | Conversational Co-Founder executing cross-module actions |

---

## 🛠️ Local Development & Setup

### Prerequisites
* Python 3.11+
* Flutter 3.29+
* Git

### Backend Setup (Django + Neon DB)

```bash
# 1. Navigate to backend
cd backend

# 2. Activate virtual environment
source ../env/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Run database migrations
python manage.py migrate

# 5. Seed initial demo data
python scripts/seed_demo_data.py

# 6. Run automated test suite
python manage.py test centria --keepdb

# 7. Start Django development server
python manage.py runserver 127.0.0.1:8000
```

### Frontend Setup (Flutter Multi-Platform)

```bash
# 1. Navigate to frontend
cd frontend

# 2. Get dependencies
flutter pub get

# 3. Run analysis & test suite
flutter analyze
flutter test

# 4. Launch Flutter Web application
flutter run -d chrome

# 5. Build for Production Web / Android
flutter build web --release
flutter build apk --release
```

---

## 🔒 Security & Privacy

* **Zero Neon Auth Dependency**: Built with custom Django JWT authentication and Brevo OTP verification.
* **Write-Once Audit Logs**: Sensitive actions generate immutable entries in the compliance audit trail.
* **Private S3 Buckets**: Documents stored with AES-256 server-side encryption within Neon Object Cloud.

---

## 📄 License & Attribution

Copyright © 2026 Centria Technologies Inc. All rights reserved. Powered by Celarox Cloud.
