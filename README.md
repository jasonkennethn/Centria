# Centria — AI-Assisted Company Operating System

[![Flutter Web](https://img.shields.io/badge/Frontend-Flutter%203.47.8-02569B?logo=flutter)](https://centria-enterprise.vercel.app/)
[![Django Backend](https://img.shields.io/badge/Backend-Django%206.1%20%2B%20Channels-092E20?logo=django)](https://centria-enterprise.onrender.com/)
[![Database](https://img.shields.io/badge/Database-Neon%20Postgres%20%2B%20pgvector-00E599?logo=postgresql)](https://neon.tech/)
[![Realtime](https://img.shields.io/badge/Realtime-Neon%20Realtime%20%2B%20WebSockets-FF6F00)](https://centria-enterprise.vercel.app/)
[![AI Engine](https://img.shields.io/badge/AI-Google%20Gemini%202.5%20Flash-4285F4?logo=google)](https://ai.google.dev/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **Centria** is an AI-assisted company and product operations platform built for small B2B software and IT-services teams.  
> **Long-term ambition:** A configurable **Company Operating System** that connects projects, Jira-style issue boards, company knowledge with vector citations, operational release gates, and real-time multiplayer updates into one unified workspace.

---

## 🌐 Live Deployments & Links

| Service | Environment | Live URL |
| :--- | :--- | :--- |
| **Centria Web Application** | Production (Vercel) | [https://centria-enterprise.vercel.app/](https://centria-enterprise.vercel.app/) |
| **Centria Backend API & Admin** | Production (Render) | [https://centria-enterprise.onrender.com/](https://centria-enterprise.onrender.com/) |
| **Realtime Neon DB Endpoint** | Cloud (Neon AWS) | `https://ep-aged-sea-b3c9bxpy.rt.c-4.ap-southeast-1.aws.neon.tech/` |
| **Source Code Repository** | GitHub | [https://github.com/jasonkennethn/Centria.git](https://github.com/jasonkennethn/Centria.git) |

---

## 🎯 What is Centria & Who is it for?

### What is Centria?
Modern software and IT-services businesses often juggle disjointed, fragmented tools: one app for task boards, another for documentation, a third for client communications, and messy chat threads for sign-offs. Centria consolidates operational chaos into an intelligent, single pane of glass:
1. **Manage work in one place:** Projects, tasks, sprint boards, bugs, and client deliverables.
2. **Instant answers grounded in company documents:** Vector-search RAG engine powered by pgvector and Gemini 2.5 Flash, providing verifiable citations side-by-side with answers.
3. **Operational gatekeeper:** Structured approval requests for release gates, budget authorizations, and scope changes with timestamped decisions.
4. **Live multiplayer reactivity:** Real-time synchronization over WebSockets powered by Neon DB Realtime and Django Channels.
5. **Integrated engineering:** GitHub repository linking for pull requests and branch synchronizations.

### Who is this for?
- **Solo Founders & Entrepreneurs:** Run an entire software or service business from one clean dashboard without tool fatigue.
- **Startups & Scale-ups:** Fast-moving product teams that need synchronized Kanban boards, live release gates, and automated audit logging.
- **B2B Software & IT-Services Teams:** Agencies managing multiple clients, milestone sign-offs, and company knowledge bases.
- **Project Managers & Tech Leads:** Streamline operational accountability with evidence-grounded AI and instant notification feeds.

---

## ⚡ Real-Time Architecture & Live Features

Centria utilizes a unified real-time architecture: **Django REST Framework** handles standard CRUD operations, **Neon DB Realtime + Django Channels (Daphne ASGI)** drives high-throughput WebSockets, and **Flutter** renders reactive UI components with zero polling.

```
┌────────────────────────────────────────────────────────┐
│               Centria Flutter Client                   │
│    (Live Synced Indicator • Notification Center)       │
└───────────────────▲────────────────────────▲───────────┘
                    │                        │
         HTTP/REST  │             WebSockets │ (JWT Query Auth)
                    ▼                        ▼
┌───────────────────────────┐  ┌─────────────────────────┐
│     Django REST Framework │  │   Django Channels ASGI  │
│    (Multi-Tenant DRF)     │  │    (Daphne Server)      │
└─────────────┬─────────────┘  └─────────────┬───────────┘
              │                              │
              ▼                              ▼
┌───────────────────────────┐  ┌─────────────────────────┐
│  Neon PostgreSQL 16 DB    │  │  Workspace & AI Groups  │
│  (pgvector + CDC Signals) │──┼─► workspace_<company_id>│
│                           │  │   user_<user_id>        │
└───────────────────────────┘  │   /ws/ai/stream/        │
                               └─────────────────────────┘
```

### Real-Time Update Capabilities

| Feature | Instant Update Trigger | What Updates Live on Screen |
| :--- | :--- | :--- |
| **Jira-Style Boards** | Task status changed, cards moved, re-assigned | Kanban cards move between columns automatically across all connected team devices with optimistic UI feedback. |
| **Tasks & Projects** | New tasks created, comments posted, progress updated | Collaborative discussions and progress badges update live. |
| **Approvals** | Approval requests submitted, approved, or rejected | Gatekeeper decision status and pending approval counters update dynamically. |
| **Notifications** | Task assignments, mentions, status alerts | In-app notification bell badge counter increments live + floating toast banners appear. |
| **AI Assistant** | User asks Centria Assistant questions | Gemini 2.5 Flash yields token chunks streamed in real time for a live typing effect. |
| **GitHub Integration** | Linked PR state transitions (open / merged / closed) | Issue/PR synchronization status reflects instantly. |
| **Dashboards** | Company audit actions, logins, creations | Live "Recent Activity" stream prepends events as they happen across the organization. |

---

## 🛠 Technology Stack

### Backend
- **Framework:** Python 3.14, Django 6.1.2, Django REST Framework 3.18.3
- **ASGI & WebSockets:** Daphne 4.2.3, Django Channels 4.3.2, `channels.layers.InMemoryChannelLayer`
- **Database:** Serverless NeonDB PostgreSQL with `pgvector` 0.8.6 extension
- **Realtime DB Engine:** Neon Realtime endpoint (`*.rt.*.aws.neon.tech`) with `nrt_live` security tokens
- **Object Cloud:** Neon Object Storage (S3-compatible) with automated AVIF image optimization
- **Authentication:** DRF SimpleJWT (JSON Web Tokens with access + refresh rotation)
- **Background Tasks:** django-q2 ORM worker cluster
- **AI & Grounding:** Google Generative AI (Gemini 2.5 Flash + text-embedding-001)
- **Email:** Brevo API transactional delivery for 6-digit OTP password resets

### Frontend
- **Framework:** Flutter 3.47.8 (Targeting Web, Desktop, Android, and iOS)
- **State Management:** Provider / `ChangeNotifier` pattern (`AuthState`, `RealtimeService`)
- **Real-Time Client:** `web_socket_channel 3.0.3` with exponential backoff auto-reconnect and heartbeat pinging
- **Typography & Styling:** Google Fonts Inter, custom curated HSL color palette, dark mode / paper theme
- **Components:** Interactive Kanban board, Slide-out AI Assistant Sheet, Real-Time Notification Center, Vector Document Search

---

## 📁 Repository Structure

```
.
├── backend/                       # Django backend service
│   ├── centria_backend/           # Project settings (base, dev, prod), WSGI, ASGI, URLs
│   ├── core/                      # Multi-tenant Company, User, dynamic Roles, OTP auth
│   │   ├── consumers.py           # WorkspaceConsumer & AIAssistantConsumer WebSockets
│   │   ├── realtime.py            # Universal sync/async broadcast dispatchers
│   │   ├── routing.py             # WebSocket URL pattern definitions
│   │   ├── signals.py             # Database hooks broadcasting live events
│   │   └── ws_auth.py             # JWT WebSocket authentication middleware
│   ├── projects/                  # Projects, Tasks (Kanban), Comments, Customers
│   ├── documents/                 # PDF/DOCX text extraction, chunking, pgvector RAG
│   ├── ai_engine/                 # Grounded AI assistant, citations, token quotas
│   ├── approvals/                 # Operational approval workflows & release gates
│   ├── integrations/              # GitHub repository linking & PR synchronization
│   ├── audit/                     # Immutable activity & compliance audit logging
│   ├── media_pipeline/            # Pillow AVIF image conversion & Neon S3 storage
│   ├── render.yaml                # Render cloud deployment specification
│   ├── requirements.txt           # Python dependency declarations
│   └── verify_realtime.py         # End-to-end automated verification check
│
├── frontend/                      # Flutter client application
│   ├── lib/
│   │   ├── main.dart              # Entry point & platform-aware initialization
│   │   ├── theme/                 # Design tokens, typography, and color palette
│   │   ├── services/              # ApiService, AuthState, RealtimeService
│   │   ├── widgets/               # AiAssistantSheet, SkeletonLoader
│   │   └── screens/               # Splash, Homepage, AppShell, Dashboard,
│   │                              # Projects, Tasks (Kanban), Knowledge, Approvals, Admin
│   ├── assets/                    # Static brand assets (logo, graphics)
│   ├── web/                       # Web icons, manifest, index.html
│   └── vercel.json                # Vercel deployment and routing rules
│
├── .gitignore                     # Git ignore rules protecting secrets and builds
└── README.md                      # Authoritative product documentation
```

---

## 🚀 Getting Started Locally

### Prerequisites
- Python 3.12+ (or 3.14)
- Flutter SDK 3.30+ (or 3.47+)
- Active Neon PostgreSQL database instance with `pgvector`

### 1. Backend Setup
```bash
# Clone the repository
git clone https://github.com/jasonkennethn/Centria.git
cd Centria

# Activate Python virtual environment
source env/bin/activate

# Install backend dependencies
cd backend
pip install -r requirements.txt

# Create your backend/.env file with the following keys:
# SECRET_KEY=your-secret-key
# DEBUG=True
# DATABASE_URL=postgresql://user:pass@ep-aged-sea-b3c9bxpy-pooler.c-4.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
# NEON_REALTIME_URL=https://ep-aged-sea-b3c9bxpy.rt.c-4.ap-southeast-1.aws.neon.tech/
# NEON_REALTIME_TOKEN=nrt_live_...
# GEMINI_API_KEY=your-gemini-key
# BREVO_API_KEY=your-brevo-key
# AWS_ENDPOINT_URL_S3=https://...storage.c-4.ap-southeast-1.aws.neon.tech
# AWS_ACCESS_KEY_ID=nak_live_...
# AWS_SECRET_ACCESS_KEY=nsk_live_...

# Run database migrations
python manage.py migrate

# Seed initial platform superadmin and demo workspace
python manage.py seed_data

# Run the end-to-end Realtime & WebSockets verification check
python verify_realtime.py

# Start the Daphne ASGI real-time development server
python -m daphne -b 0.0.0.0 -p 8000 centria_backend.asgi:application
```

### 2. Frontend Setup
```bash
cd ../frontend

# Install Flutter dependencies
flutter pub get

# Run test suite
flutter test

# Run the web application in Chrome
flutter run -d chrome

# Or build optimized production bundle
flutter build web --release
```

---

## 🔐 Default Demo Accounts

For instant access and evaluation, the seed dataset provides two pre-configured accounts:

| Role | Email | Password | Scope |
| :--- | :--- | :--- | :--- |
| **Platform Superadmin** | `jasonkennethn@gmail.com` | `CentriaAdmin@2026!` | Global multi-company overview, plan management, and tenant metrics |
| **Demo Workspace Lead** | `priya@northstar.io` | `Northstar@2026!` | Northstar Studio workspace, projects, Kanban tasks, approval requests |

---

## 🛡️ Security, Privacy & Safety

- **Zero-Exposure Secret Management:** All API keys (Gemini, Brevo, Neon Realtime tokens, S3 keys) are strictly loaded via environment variables and excluded from git tracking via `.gitignore`.
- **Tenant Isolation:** Every operational model extends `TenantModel`, guaranteeing multi-tenant organization boundaries at the ORM layer.
- **WebSocket Protection:** WebSockets enforce JWT authentication at the ASGI handshake boundary; unauthorized connections are rejected before joining broadcast groups.
- **Audit Immutability:** Sensitive operations (logins, exports, AI queries, approvals) record irreversible audit records with IP tracking.

---

## 👨‍💻 Author & Contact

**Jason Kenneth N**  
- **Email:** [jasonkennethn@gmail.com](mailto:jasonkennethn@gmail.com)  
- **GitHub:** [@jasonkennethn](https://github.com/jasonkennethn)  
- **Repository:** [jasonkennethn/Centria](https://github.com/jasonkennethn/Centria)  

---

*Centria — Designed and crafted for modern software teams to execute, align, and operate with clarity.*
