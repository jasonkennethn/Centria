# CENTRIA — India's Sovereign Company Operating System

![Centria Platform](frontend/assets/images/logo.jpg)

**Centria** is the unified Company Operating System engineered for Indian founders, directors, and growing enterprises. Connecting corporate governance, MCA/ROC statutory filings, GST compliance, banking enclaves, and autonomous workflows into one high-integrity workspace.

---

## 🇮🇳 India-First Corporate Architecture

Centria is purpose-built to operate under Indian sovereign regulatory frameworks:

- **Corporate Jurisdiction:** Ministry of Corporate Affairs (MCA V3 Portal) & Registrar of Companies (ROC Bangalore, ROC Mumbai, ROC Hyderabad).
- **Statutory Tracking:** Automated filing radar for Form AOC-4, Form MGT-7, Form DIR-12, GST GSTR-3B & GSTR-1, ITD Advance Tax & TDS Section 194J, and EPFO/ESIC remittances.
- **National Currency:** Indian Rupee (INR / ₹) with native Indian numbering formatting (Lakhs & Crores).
- **Banking Enclaves:** Multi-account treasury support across HDFC Bank, ICICI Bank, and State Bank of India (SBI).
- **Enterprise Integrations:** Native adapters for **Razorpay** (UPI & NetBanking auto-reconciliation), **Zoho Books** (E-Invoicing & E-Way Bill sync), **TallyPrime** (MCA Rule 3 audit trail), and **AWS India ap-south-1** (Sovereign KMS Enclave).

---

## 🏛️ System Architecture

Centria pairs a **modular Django monolith** backend with an adaptive **Flutter cross-platform client**:

```
[Flutter Client (Web, Android APK, iOS)]
                │
                ▼ HTTPS / REST (Versioned /api/v1/)
[Django Core Modular Monolith]
  ├── accounts        (User Identity, FIDO2 / Passkey Auth)
  └── enterprise      (Sovereign Multi-Tenant Domain)
        ├── Company & Membership (CIN, GSTIN, PAN, TAN, DIN)
        ├── Tasks & Executive Project Streams
        ├── Biometric Approvals (SHA-256 Merkle Block Hash)
        ├── Banking Enclaves (HDFC, ICICI, SBI)
        ├── Statutory Radar (MCA, GSTN, ITD, EPFO, ESIC)
        └── Integrations (Razorpay, Zoho Books, TallyPrime)
                │
                ▼
  [Neon Serverless PostgreSQL (Pooler, SSL, Asia/Kolkata)]
```

---

## 🔒 Multi-Tenant Data Isolation

- Every business record (`Task`, `ApprovalRequest`, `BankBalance`, `StatutoryObligation`, `AuditEvent`) is strictly scoped to an active `Company` tenant.
- Tenant context is resolved server-side through membership authorization and the `X-Company-ID` request header.
- Cross-tenant data access attempts return safe `HTTP 404 Not Found` responses to prevent IDOR and existence inference.
- Every approval execution produces a deterministic cryptographic SHA-256 Merkle root hash chained into an immutable `AuditEvent` ledger.

---

## 🚀 Local Development & Testing

### 1. Backend (Django + Neon PostgreSQL)

```bash
# Navigate to repository root
cd DEVELOPMENT

# Activate virtual environment
source env/bin/activate

# Install dependencies (if needed)
pip install -r backend/requirements.txt

# Run migrations against Neon PostgreSQL
python backend/manage.py migrate

# Run tenant isolation & API test suite
python backend/manage.py test enterprise accounts

# Start the Django development server
python backend/manage.py runserver 8000
```

### 2. Frontend (Flutter)

```bash
# Navigate to frontend directory
cd frontend

# Analyze Dart code for precision quality (0 issues)
flutter analyze

# Run Flutter automated test suite
flutter test

# Run Flutter app locally (Web)
flutter run -d chrome

# Build production web bundle
flutter build web --release
```

---

## 🌐 Production Deployments

| Component | Provider | Live Production URL |
| :--- | :--- | :--- |
| **Web Application** | Vercel Edge Network | [https://centria-enterprise.vercel.app/](https://centria-enterprise.vercel.app/) |
| **API Backend** | Render Cloud Services | [https://centria-enterprise.onrender.com/](https://centria-enterprise.onrender.com/) |
| **Database** | Neon Cloud | Serverless PostgreSQL (ap-southeast-1 Pooler, SSL) |

---

## 📚 Technical Documentation

Detailed architectural and engineering documentation is available under `backend/docs/`:

- [System Architecture](backend/docs/architecture.md)
- [Data Model & Mermaid ER Diagram](backend/docs/data-model.md)
- [REST API v1 Contract](backend/docs/api-contract.md)
- [Sovereign Integrations Specification](backend/docs/integrations.md)

---

## 👨‍💼 Author & Leadership

**Lead Developer & Architect:**  
**Jason Kenneth N**  
- **GitHub**: [@jasonkennethn](https://github.com/jasonkennethn)  
- **Repository**: [https://github.com/jasonkennethn/Centria](https://github.com/jasonkennethn/Centria)  
- **Contact**: `jasonkennethn@gmail.com`  

*Centria — India's Sovereign Company Operating System. Engineered with precision.*
