---
id: 015
title: Backend Billing Checkout and Confirmation Contract Tests
status: done
priority: high
labels: [testing, backend, billing, api, contract]
estimate: medium
created: 2026-02-11
updated: 2026-02-12
---

# User Story

As a frontend and backend developer,
I want stable billing API contracts,
So that checkout, success, and subscription state flows remain reliable.

# Problem Statement

Billing behavior is conversion-critical and FE depends on specific status and error semantics (`already_subscribed`, payment incomplete, active/trialing status). We need explicit API contract coverage around checkout and confirmation.

# Proposed Solution (High-Level)

Consolidate and expand billing router contract tests for:
- `POST /billing/checkout`
- `POST /billing/checkout/confirm`
- `GET /billing/status`
- `POST /billing/webhook` (core contract cases)

# Acceptance Criteria

- [x] `/billing/checkout` covers success, `already_subscribed` conflict, and generic failure paths
- [x] `/billing/checkout/confirm` covers active/trialing success and payment_incomplete behavior
- [x] `/billing/status` covers active and empty/non-active subscription states
- [x] Webhook contract tests cover signature/invalid payload handling and key event paths
- [x] Error contract shape (`detail`) and status codes are explicitly asserted
- [x] Tests pass in backend test workflow

# Technical Context

## Current State
- Router implementation: `/backend/tenderbot/api/routers/billing.py`
- Existing router tests: `/backend/tests/unit/tenderbot/api/routers/test_billing.py`
- Billing domain/repo tests already exist under `/backend/tests/unit/tenderbot/core/billing/` and `/backend/tests/unit/tenderbot/data/billing/`

## Proposed Changes
- Expand billing router contract assertions for FE-consumed semantics
- Ensure `409 already_subscribed`, `402 payment_incomplete`, and `400` fallback behaviors are protected
- Add focused webhook contract coverage where gaps exist

## File Locations
- `/backend/tests/unit/tenderbot/api/routers/test_billing.py`
- Optional split module if needed:
  - `/backend/tests/api/test_billing_contracts.py`

# Open Questions

- [x] Treat webhook coverage as part of this ticket? **Yes, for core event contract and error handling.**
- [x] Include Stripe live/test integration calls? **No, use deterministic fake stripe client behavior.**

# Dependencies

- Parent epic: Story #003
- Related FE consumer: Story #012

# Implementation Tasks

## Task 1: Define billing contract matrix (30 min)
- Capture required request/response keys and status codes for checkout, confirm, status, and webhook.
- Verification: each matrix row maps to at least one test.

## Task 2: Expand checkout and confirm contract tests (50 min)
- Add explicit assertions for conflict, incomplete payment, and generic error payloads.
- Verification: tests assert both status code and error detail string.

## Task 3: Expand status endpoint contract coverage (30 min)
- Assert behavior for active, trialing, and no-subscription states.
- Verification: response schema remains FE-compatible across states.

## Task 4: Add webhook contract tests (45 min)
- Cover missing signature, invalid signature, invalid payload, and successful subscription upsert events.
- Verification: webhook endpoint returns predictable status/body.

## Task 5: Run backend test suite and stabilize (25 min)
- Run `mise run test` and fix brittle assumptions.

# Notes

This story secures backend contract behavior used by FE onboarding completion and success flows.
