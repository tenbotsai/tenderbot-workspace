---
id: 016
title: Backend Dashboard API Contract Tests
status: refined
priority: high
labels: [testing, backend, dashboard, api, contract]
estimate: medium
created: 2026-02-11
updated: 2026-02-11
---

# User Story

As a frontend and backend developer,
I want stable dashboard API contracts,
So that dashboard tabs render correctly across loading, empty, success, and error states.

# Problem Statement

Dashboard FE relies on multiple endpoints with tab-specific fetch patterns. Contract regressions can silently break tabs even when unit tests pass in isolation.

Endpoints in scope:
- `GET /alert-profiles/latest/matches`
- `GET /customers/{id}/alert-profiles`
- `GET /customers/{id}/saved-tenders`
- `GET /delivery-history`
- `GET /delivery-history/{id}/preview`

# Proposed Solution (High-Level)

Add backend API contract tests focused on response shapes, auth behavior, pagination semantics, and preview error handling for dashboard endpoints.

# Acceptance Criteria

- [ ] Contract tests cover all dashboard endpoints in scope
- [ ] Response payload keys/types used by FE tabs are asserted
- [ ] Auth/permission failure behavior is asserted where applicable
- [ ] Delivery history pagination (`limit`, `offset`) contract is asserted
- [ ] Preview endpoint contract covers found/not-found/error paths
- [ ] Tests pass in backend test workflow

# Technical Context

## Current State
- Existing tender matches router tests: `/backend/tests/unit/tenderbot/api/tender_matches/test_tender_matches_router.py`
- Existing saved tenders router tests: `/backend/tests/unit/tenderbot/api/saved_tenders/test_saved_tenders_router.py`
- Existing delivery history router tests: `/backend/tests/unit/tenderbot/api/delivery_history/test_delivery_history_router.py`

## Proposed Changes
- Add a contract-focused aggregation layer for dashboard endpoints
- Keep endpoint behavior assertions aligned with FE Story #013 tab expectations

## File Locations
- Existing test suites above
- Optional consolidating module:
  - `/backend/tests/api/test_dashboard_contracts.py`

# Open Questions

- [x] Keep tests split by router or aggregate by FE surface? **Aggregate by FE surface while reusing router-level tests.**
- [x] Include performance assertions? **No, contract correctness only.**

# Dependencies

- Parent epic: Story #003
- Related FE consumer: Story #013

# Implementation Tasks

## Task 1: Build dashboard endpoint contract checklist (30 min)
- Document required fields used by feed/alerts/saved/history tabs.
- Verification: checklist maps 1:1 to test assertions.

## Task 2: Add matches and alerts contract assertions (40 min)
- Assert key field presence/types and handling for empty/non-empty responses.
- Verification: tests fail when schema drifts.

## Task 3: Add saved tenders contract assertions (35 min)
- Assert saved tenders payload shape and auth constraints.
- Verification: successful and forbidden cases covered.

## Task 4: Expand delivery history and preview contracts (45 min)
- Assert pagination behavior and preview status/error semantics.
- Verification: FE can rely on stable response handling.

## Task 5: Run backend tests and stabilize (25 min)
- Run `mise run test` and address fixture brittleness.

# Notes

This story is API-contract focused and should not include frontend code changes.
