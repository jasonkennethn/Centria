# CENTRIA — System Architecture & Sovereign Monolith Specification

## 1. Executive Summary & India-First Mandate
**Centria** is the Company Operating System engineered for Indian founders, directors, and fast-growing enterprises. Dedicated to sovereign Indian corporate operations, Centria streamlines statutory compliance, board governance, treasury liquidity, and multi-departmental operations into one high-integrity workspace.

- **Primary Legal Context:** India Companies Act 2013, Ministry of Corporate Affairs (MCA V3 Portal), Goods and Services Tax Network (GSTN), Income Tax Department (ITD), EPFO, and ESIC.
- **National Jurisdiction:** Registrar of Companies (ROC Bangalore, ROC Mumbai, ROC Hyderabad).
- **Core Currency:** Indian Rupee (INR / ₹) with native Lakhs (₹L) and Crores (₹Cr) accounting formatting.
- **Timezone:** `Asia/Kolkata` (IST) across all database timestamps and scheduled obligations.

---

## 2. Architectural Paradigm: Modular Monolith
To maximize operational velocity, transactional integrity, and data isolation, Centria is structured as a **modular Django monolith** paired with a multi-platform **Flutter frontend**.

```
[Flutter Client (Web, Android, iOS)]
                │
                ▼ HTTPS / REST (Versioned /api/v1/)
[Django Core Application Gateway]
        │               │
        ▼               ▼
[Accounts Service]   [Enterprise Sovereign App]
 (Identity & RBAC)    ├── Company & Tenancy Boundary (CIN, GSTIN, PAN, TAN)
                      ├── Tasks & Executive Project Streams
                      ├── Biometric Approvals & Merkle Root Hashes
                      ├── Banking Enclaves (HDFC, ICICI, SBI)
                      ├── Statutory Radar (MCA, GSTN, ITD, EPFO, ESIC)
                      └── Enterprise Integrations (Razorpay, Zoho, Tally)
                                │
                                ▼
        [Neon PostgreSQL (ap-southeast-1 pooler, SSL)]
```

### Key Architectural Strengths
1. **Zero Unnecessary Distributed Complexity:** No brittle microservice networking for intra-domain transactions.
2. **ACID Transactions:** Financial ledger updates and approval state transitions commit transactionally with cryptographic SHA-256 Merkle block proofs.
3. **Strict Tenant Isolation:** Every request is authenticated and verified against an authorized `Company` workspace via the `X-Company-ID` context header.

---

## 3. Sovereign Indian Integrations Matrix
| Connector | Category | Purpose | SLA / Status |
| :--- | :--- | :--- | :--- |
| **Razorpay Enterprise** | Payments | UPI, NetBanking, and Auto-Reconciliation of receivables | 99.98% SLA · Connected |
| **Zoho Books** | Cloud Accounting | Automated E-Way Bill and E-Invoicing GST synchronization | 99.95% SLA · Connected |
| **TallyPrime Server** | On-Premise ERP | MCA Rule 3 compliant continuous audit trail backup | 99.90% SLA · Connected |
| **AWS India (Mumbai)** | Infrastructure | Sovereign KMS Enclave for director biometric key derivation | 99.99% SLA · Connected |

---

## 4. Security & Cryptographic Audit Model
- **Director Biometric Passkey Signing:** Every high-value approval (Capex, statutory returns, banking instructions) triggers a local biometric sign-off via WebAuthn / TouchID / FaceID.
- **Merkle Block Hash:** Approvals generate an irreversible `0x...` SHA-256 hash chaining into `AuditEvent` records with block height and timestamp.
- **Tenant Isolation Defense:** Cross-tenant access attempts return HTTP 404 to avoid leaking resource existence across corporate boundaries.
