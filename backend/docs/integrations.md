# CENTRIA — Sovereign Integrations Architecture (India-First)

Centria connects external Indian specialist platforms through secure backend-only connector adapters. Client secrets, API keys, and webhook signing tokens are never exposed to the Flutter frontend.

---

## 1. Razorpay Enterprise Payment Gateway
- **System of Record:** Inbound customer receipts and UPI autopay mandates.
- **Protocol:** REST API + HMAC-SHA256 Webhook Verification.
- **Security & Scopes:**
  - Webhooks signed via `X-Razorpay-Signature`.
  - Replay protection: 300-second timestamp drift tolerance.
- **Workflow:** Automatically matches incoming UPI/NEFT/RTGS payments against issued invoices and adjusts real-time bank ledger balances.

---

## 2. Zoho Books Cloud Accounting
- **System of Record:** GST Invoices, E-Way Bills, and Vendor Bills.
- **Protocol:** OAuth 2.0 (Authorization Code + PKCE) to `accounts.zoho.in`.
- **Scopes:** `ZohoBooks.invoices.READ`, `ZohoBooks.expenses.CREATE`.
- **Workflow:** Synchronizes approved Capex items and vendor invoices into Zoho Books and retrieves GST E-Invoice IRN details.

---

## 3. TallyPrime Server Connector
- **System of Record:** On-Premise Audit Trail Ledger (MCA Rule 3 Compliance).
- **Protocol:** XML / JSON over TLS Agent Connector.
- **Purpose:** Continuous replication of daybook vouchers to Centria's immutable sovereign ledger, ensuring audit compliance under Section 128 of the Companies Act 2013.

---

## 4. AWS India (Mumbai `ap-south-1`) Sovereign HSM
- **System of Record:** Key Management & Cloud Hardware Security Modules (CloudHSM).
- **Purpose:** Cryptographic signing of Merkle audit blocks and director biometric attestation validation.
- **Data Residency:** All database backups and transaction records remain strictly within Indian territorial boundaries.
