# Centria — Company Operating System

> AI-assisted company and product operations platform for small B2B software and IT-services teams.  
> Long-term ambition: a configurable Company Operating System connecting projects, issues, knowledge, and operational approvals in one unified workspace.

---

## 🚀 Live Deployments

- **Frontend Application (Vercel):** [https://centria-enterprise.vercel.app/](https://centria-enterprise.vercel.app/)
- **Backend API & Admin (Render):** [https://centria-enterprise.onrender.com/](https://centria-enterprise.onrender.com/)
- **GitHub Repository:** [https://github.com/jasonkennethn/Centria.git](https://github.com/jasonkennethn/Centria.git)

---

## 🛠 Tech Stack

| Component | Technology | Purpose |
|---|---|---|
| **Frontend** | Flutter (Web + Android + iOS) | Responsive web & native mobile interfaces with zero-lag skeleton loading |
| **Backend** | Django 5.x / 6.x + DRF + django-q2 | Multi-tenant REST APIs, background task queue & audit trail |
| **Database** | NeonDB (PostgreSQL + pgvector) | Serverless relational storage with native 3072-dim vector cosine similarity |
| **Object Cloud** | Neon Object Cloud (S3-compatible) | High-fidelity AVIF image compression pipeline & document store |
| **Grounded AI** | Google Gemini (2.5 Flash + Embedding 001) | Ground-truth AI assistant with verifiable citations |
| **Transactional Email** | Brevo API (`no-reply@celarox.com`) | 6-digit OTP verification & password recovery |
| **Deployment** | Vercel (Frontend) + Render (Backend) | Continuous cloud deployment with auto SSL & security headers |

---

## 📁 Repository Structure

```
├── backend/                  # Django backend service
│   ├── centria_backend/      # Project settings (base, dev, prod), WSGI, ASGI, URLs
│   ├── core/                 # Multi-tenant Company, User, dynamic Roles, OTP auth
│   ├── projects/             # Projects, Tasks (Kanban), Task Comments, Customers
│   ├── documents/            # PDF/DOCX text extraction, chunking, pgvector indexing
│   ├── ai_engine/            # Grounded AI assistant, RAG citations, quota manager
│   ├── approvals/            # Operational approval workflows & release gates
│   ├── integrations/         # GitHub repository linking & PR synchronization
│   ├── audit/                # Immutable activity & compliance audit logging
│   ├── media_pipeline/       # Pillow AVIF image conversion & Neon S3 storage
│   ├── render.yaml           # Render deployment configuration
│   └── requirements.txt      # Python dependencies
│
├── frontend/                 # Flutter application (Web & Mobile)
│   ├── lib/
│   │   ├── main.dart         # Entry point & platform-aware routing
│   │   ├── theme/            # Design system, Inter typography & curated colors
│   │   ├── services/         # ApiService (REST HTTP) & AuthState (ChangeNotifier)
│   │   ├── widgets/          # AiAssistantSheet, SkeletonLoader
│   │   └── screens/          # Splash (0.6s), Homepage, AppShell, Dashboard,
│   │                         # Projects, Tasks (Kanban), Knowledge, Approvals, Admin
│   ├── assets/               # Branding assets (logo.png)
│   ├── web/                  # Web manifest, icons, index.html
│   └── vercel.json           # Vercel deployment configuration
│
└── .gitignore                # Git ignore rules for secrets, builds, and venv
```

---

## 🔑 Key Features

### 1. Multi-Tenant Workspace Isolation
- Dynamic company isolation enforced on every query via `CompanyIsolationMiddleware`.
- Granular role permissions (`Owner`, `Admin`, `Project Manager`, `Member`, `Viewer`).
- Platform superadmin portal for `jasonkennethn@gmail.com`.

### 2. Evidence-First Grounded AI (RAG)
- Upload PDF, Word (`.docx`), and Markdown documents.
- Chunks and embeds text using 3072-dimensional Gemini embeddings stored in NeonDB pgvector.
- Retrieves exact citations with similarity match percentages displayed side-by-side with assistant answers.

### 3. Integrated Project & Issue Execution
- Interactive Kanban boards (To Do, In Progress, In Review, Done).
- Link GitHub branches, pull requests, and commits directly to task cards.
- Customer management CRM for B2B client deliverables.

### 4. Operational Gatekeeper & Approval Workflows
- Submit release gatekeeper approvals, scope modifications, and budget requests.
- Designated approvers review, sign off, or reject with timestamped decision notes.
- Immutable audit log tracking all actions across the organization.

### 5. Media Pipeline with AVIF Optimization
- Any uploaded image is automatically transformed into AVIF format via Pillow.
- Reduces asset payloads by up to 80% while retaining high visual fidelity.
- Stored directly in Neon Object Cloud S3.

---

## ⚡ Getting Started Locally

### 1. Backend Setup
```bash
# Clone the repository
git clone https://github.com/jasonkennethn/Centria.git
cd Centria

# Activate the virtual environment
python3 -m venv env
source env/bin/activate

# Install backend dependencies
cd backend
pip install -r requirements.txt

# Configure backend/.env
# (Populate DATABASE_URL, GEMINI_API_KEY, BREVO_API_KEY, AWS_* credentials)

# Run migrations and seed data
python manage.py migrate
python manage.py seed_data

# Start development server
python manage.py runserver 0.0.0.0:8000
```

### 2. Frontend Setup
```bash
cd ../frontend

# Fetch Flutter dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Or build release web bundle
flutter build web --release
```

### 3. Default Demo Credentials
- **Platform Superadmin:** `jasonkennethn@gmail.com` / `CentriaAdmin@2026!`
- **Demo Workspace Lead:** `priya@northstar.io` / `Northstar@2026!`
