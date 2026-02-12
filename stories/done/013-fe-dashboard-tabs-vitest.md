---
id: 013
title: Vitest Coverage for Dashboard Tab Flows
status: done
priority: high
labels: [testing, frontend, vitest, dashboard]
estimate: medium
created: 2026-02-11
updated: 2026-02-11
---

# User Story

As a developer,
I want meaningful Vitest coverage for dashboard tabs,
So that users can reliably use feed, alerts, saved, history, and settings flows.

# Problem Statement

Current dashboard tests focus on utility-style logic and response shapes. They do not sufficiently verify tab-driven page behavior and fetch trigger conditions.

The dashboard page has multiple effects keyed by auth state, `activeTab`, and `customerId`, making it a high-regression surface.

# Proposed Solution (High-Level)

Add page-level Vitest tests for dashboard tabs with mocked auth and API responses.

Coverage focus:
1. initial auth-gated load behavior
2. tab switching and fetch trigger rules
3. loading/empty/error display states per major tab
4. history tab pagination and preview fetch behavior

# Acceptance Criteria

- [ ] Tests cover all 5 tabs (feed, alerts, saved, history, settings)
- [ ] Auth-gated behavior is tested for authenticated and unauthenticated states
- [ ] Feed tab tests loading, empty, success, and fetch error fallback
- [ ] Alerts/saved tab tests fetch trigger conditions and empty/success states
- [ ] History tab tests initial load, load-more behavior, and preview load path
- [ ] Tests use Story #010 shared fixtures/utilities
- [ ] `npm run test:unit` passes

# Technical Context

## Current State
- Dashboard page: `/signup/app/routes/dashboard/page.tsx`
- Uses `AuthGuard` and `useAuth`: `/signup/app/components/auth.tsx`
- Uses `apiFetch`: `/signup/app/lib/api.ts`
- Existing dashboard test file: `/signup/tests/unit/dashboard/page.test.tsx`

## Proposed Changes
- Replace/extend dashboard tests with page-behavior assertions
- Mock toast/router only where interaction handlers require it
- Keep tests focused on user-visible behavior and fetch calls

## File Locations
- New or updated test file:
  - `/signup/tests/unit/dashboard/page.test.tsx`

# Open Questions

- [x] Separate fixtures per tab or shared fixture package? **Shared dashboard fixture module with per-tab exports.**
- [x] Critical-path order if time-constrained? **Feed -> Alerts -> Saved -> History -> Settings.**

# Dependencies

- Parent: Story #003
- Foundation: Story #010

# Implementation Tasks

## Task 1: Build dashboard page render harness (35 min)
- Update `/signup/tests/unit/dashboard/page.test.tsx` to render dashboard page component, mock `useAuth`, mock `apiFetch`, and support tab clicks.
- Verification: harness test can switch tabs and assert active content.

## Task 2: Feed tab behavior tests (35 min)
- Add tests for:
  - loading state while fetch pending
  - empty state when no matches
  - successful match render
  - fetch failure fallback to empty state
- Verification: assertions use visible UI text and card content.

## Task 3: Alerts and saved tab behavior tests (40 min)
- Add tests for:
  - customer identify call gating
  - alerts fetch only when tab active and customer ID exists
  - saved fetch only when saved tab active and customer ID exists
  - empty and success render paths
- Verification: call count and endpoint assertions pass.

## Task 4: History tab behavior tests (45 min)
- Add tests for:
  - initial history fetch on tab open
  - selecting a delivery triggers preview fetch
  - load-more increments page and triggers next fetch
  - error fallback when preview unavailable
- Verification: endpoint calls and preview area assertions pass.

## Task 5: Settings tab baseline test + regression run (20 min)
- Add one test ensuring settings content renders without extra API calls.
- Run `npm run test:unit` and stabilize mocks/timers.

# Notes

Do not add Playwright coverage in this story. Keep all tests deterministic and fast in Vitest.
