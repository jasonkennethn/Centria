# Centria — Implementation Notes

## Architecture Overview
- **Framework**: Flutter (Dart 3.7.0 / Flutter 3.29.0)
- **Target Platforms**: Web (responsive), Android (APK), iOS (source-compatible)
- **Design System**: "Executive Precision" Light Theme based on `DESIGN.md`
- **Routing**: `go_router` (declarative, deep-linkable URLs, web refresh and browser back/forward supported)
- **State & Repositories**: Pure Dart demo repositories with deterministic local state, uncoupled from UI widgets for clean future backend integration.
- **Typography**: Google Fonts `Inter` for UI body/display/labels, `JetBrains Mono` for financial figures, tabular data, hashes, and percentages.

## Color Tokens & Semantics
- **Canvas Base**: `#FBFBF9` (Warm Canvas Default)
- **Canvas Subdued / Recessed**: `#F8F8F6` (Sidebar navigation, segmented controls, table headers)
- **Surface Card**: `#FFFFFF` (Primary elevated containers, modal sheets, popovers)
- **Surface Inset**: `#F1F5F9` (Read-only data wells, code snippets, calculation logs)
- **Structural Stroke / Hairline**: `#E2E8F0` (Default perimeter line for all cards and table rows)
- **Structural Stroke Strong**: `#CBD5E1` (Input bounds, active dividers, splitters)
- **Primary 900 (Dominant)**: `#0C4A45` (Headers, active navigation states, primary buttons)
- **Primary 700 (Interactive)**: `#0F766E` (Hover states, text links, selected tab underlines)
- **Primary 500 (Accent)**: `#14B8A6` (Focus rings, key metrics indicators, metric deltas)
- **Cognitive Deep (AI Layer)**: `#6D28D9` (Machine-generated confidence scores, AI action triggers)
- **Cognitive Surface Tint**: `#F5F3FF` (Suggested diffs and synthetic summaries)
- **Semantic Statuses**:
  - Verified / Compliance: `#059669` foreground on `#ECFDF5` background (Border: `#A7F3D0`)
  - Attention / Pending: `#D97706` foreground on `#FFFBEB` background (Border: `#FDE68A`)
  - Critical / Blocker: `#DC2626` foreground on `#FEF2F2` background (Border: `#FECACA`)
  - Informational: `#2563EB` foreground on `#EFF6FF` background (Border: `#BFDBFE`)

## Demo Mode & Truth in Advertising
- A persistent, unobtrusive `Demo Mode / Sample Data` banner is present across all authenticated workspace views.
- Actions (such as "Authorize CT600 Filing (Biometric)", "Rotate mTLS Key", "Ratify DORA Attestation") update deterministic local state and present honest toast/dialog confirmations stating: *"Demo action recorded locally — no external authority notified"*.
- No fake external network calls, no imaginary endpoints, no data loss.

## Future API Integration Seams
- All data models (`TaskItem`, `ApprovalItem`, `FinancialMetric`, `EntityNode`, `AuditEntry`, `NotificationItem`) are decoupled from widgets.
- Real API clients (e.g. connecting to the existing `ApiService` or GraphQL/REST endpoints) can implement the abstract repository interfaces without altering UI components.
