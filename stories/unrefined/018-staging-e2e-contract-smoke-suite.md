---
id: 018
title: Staging E2E Contract Smoke Suite
status: unrefined
priority: medium
labels: [testing, backend, frontend, staging, e2e]
estimate: unknown
created: 2026-02-11
updated: 2026-02-11
---

# User Story

As a developer,
I want a staging smoke suite that validates end-to-end contracts,
So that we can catch integration regressions before production releases.

# Problem Statement

Local FE/BE tests provide strong isolated confidence, but they do not validate full staging behavior across auth, onboarding, billing, and dashboard flows.

Without staging smoke coverage, deployment regressions can slip through despite passing unit and API contract tests.

# Proposed Solution (High-Level)

Create a staging-focused smoke suite that runs against deployed staging services and validates core user journey contracts.

Potential smoke scope:
- Auth login callback and protected routes
- Onboarding contract chain to preview
- Billing checkout success/cancel plumbing (test mode)
- Dashboard feed/alerts/history API and UI availability

# Acceptance Criteria

- [ ] Smoke suite plan and tool choice defined (Playwright/API hybrid or equivalent)
- [ ] Staging environment prerequisites documented and validated
- [ ] Critical path smoke tests identified with owners and execution cadence
- [ ] Failure triage and rollback response process documented
- [ ] Initial smoke suite runs successfully on staging

# Technical Context

## Current State
- FE Vitest stories cover frontend behavior locally
- Backend contract stories cover API behavior locally
- Staging setup tracked in Story #004

## Proposed Changes
- Define and implement lightweight staging smoke checks as a deploy gate
- Reuse deterministic test accounts/data in staging where possible

## File Locations
- Staging env story: `/stories/unrefined/004-staging-environment.md`
- FE onboarding/dashboard routes: `/signup/app/routes/`
- Backend API routes: `/backend/tenderbot/api/routers/`

# Open Questions

- [ ] Which runner should own staging smoke checks (Playwright, API-only, or mixed)?
- [ ] Should smoke checks run on every deploy or scheduled intervals?
- [ ] How should staging test data be seeded and reset?
- [ ] What is the minimum reliable smoke set for day-one?

# Dependencies

- Story #004 (staging environment)
- Story #014 (onboarding backend contracts)
- Story #015 (billing backend contracts)
- Story #016 (dashboard backend contracts)

# Notes

Keep this story unrefined until staging environment decisions and deployment workflow are settled.
