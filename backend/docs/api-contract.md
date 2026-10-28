# CENTRIA — Sovereign REST API v1 Contract

Base URL: `/api/v1/`  
Auth Header (Optional Tenant Override): `X-Company-ID: <UUID>`

---

## 1. Executive Cockpit Overview
- **Endpoint:** `GET /api/v1/overview/`
- **Description:** Returns the consolidated executive overview: total liquid cash in INR, runway months, statutory compliance percentage, and live counters.
- **Response Format:**
```json
{
  "company": {
    "id": "c8f2a1b0-4e3d-4c5b-9a8f-2c3b4e5d6a7b",
    "name": "Centria Technologies India Pvt Ltd",
    "cin": "U72900KA2024PTC189201",
    "gstin": "29AABCC1234F1Z5",
    "pan": "AABCC1234F",
    "tan": "BLRC12345D",
    "roc_jurisdiction": "ROC Bangalore (Karnataka)",
    "registered_office": "Level 4, Embassy TechVillage, Outer Ring Road, Bengaluru, Karnataka 560103"
  },
  "metrics": {
    "total_cash_inr": "58421000.00",
    "total_cash_display": "₹5,84,21,000",
    "runway_months": "18.4 Months Runway",
    "statutory_health_percent": "99.4%",
    "statutory_health_status": "14/15 MCA & GST Filings Complete",
    "pending_approvals_count": 3,
    "active_tasks_count": 4,
    "active_integrations_count": 4
  },
  "recent_audits": [ ... ]
}
```

---

## 2. Tasks & Projects Stream
- **List / Query Tasks:** `GET /api/v1/tasks/?status=IN_PROGRESS`
- **Create Task:** `POST /api/v1/tasks/`
  - Body: `{"task_code": "TSK-IN-105", "title": "...", "priority": "HIGH", "status": "TODO"}`
- **Retrieve Task:** `GET /api/v1/tasks/{id}/`
- **Patch Task:** `PATCH /api/v1/tasks/{id}/`
  - Body: `{"status": "COMPLETED"}`
- **Delete Task:** `DELETE /api/v1/tasks/{id}/` (Returns 204 No Content)

---

## 3. Sovereign Approvals & Cryptographic Ratification
- **List Approvals:** `GET /api/v1/approvals/?status=PENDING`
- **Execute Biometric Ratification:** `POST /api/v1/approvals/{id}/execute/`
  - Body:
    ```json
    {
      "action": "APPROVE",
      "decision_note": "Biometric ratification completed via Director Secure Enclave."
    }
    ```
  - **Outcome:** Generates SHA-256 Merkle root hash (e.g. `0x9a8f...`), transitions status to `EXECUTED`, and appends an immutable `AuditEvent` block.

---

## 4. Financial Enclaves & Banking
- **Endpoint:** `GET /api/v1/finance/`
- **Description:** Returns balances across HDFC Bank, ICICI Bank, and SBI in INR, along with active RuPay/Visa corporate cards.

---

## 5. Statutory Obligations Radar
- **Endpoint:** `GET /api/v1/statutory/`
- **Description:** Returns filing statuses, authorities (MCA, GSTN, ITD, EPFO, ESIC), due dates, and liabilities.

---

## 6. Enterprise Integrations
- **Endpoint:** `GET /api/v1/integrations/`
- **Description:** Real-time health status of Razorpay, Zoho Books, TallyPrime, and AWS Sovereign Enclave connectors.
