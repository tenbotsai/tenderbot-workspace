---
id: 012
title: Vitest Coverage for Onboarding Steps 6-7 and Billing Redirects
status: done
priority: high
labels: [testing, frontend, vitest, onboarding, billing]
estimate: medium
created: 2026-02-11
updated: 2026-02-11
---

# User Story

As a developer,
I want Vitest coverage for onboarding completion and billing flows,
So that conversion-critical behavior is reliable and regressions are detected early.

# Problem Statement

Step 6 (tender preview), step 7 (plan), and billing redirects are orchestration-heavy and API-dependent. Existing tests do not sufficiently cover page-level checkout branches and success/cancel handling.

# Proposed Solution (High-Level)

Add deterministic Vitest coverage for onboarding completion behavior, checkout initiation branches, and success-page verification flow.

Coverage focus:
1. step-6 preview states and API orchestration
2. step-7 plan selection and completion transition
3. checkout API response branches and redirect behavior
4. success page confirmation/status handling
5. cancel page baseline rendering/link behavior

# Acceptance Criteria

- [ ] Step 6 tests cover loading, populated, empty, and error states
- [ ] Step 7 tests cover plan selection and completion transition
- [ ] Onboarding page tests cover `/billing/checkout` success, failure, and `already_subscribed` branch
- [ ] Redirect behavior is asserted using spies (no real navigation/payment)
- [ ] Success page tests cover `/billing/checkout/confirm` and `/billing/status` outcomes
- [ ] Cancel page test asserts user can return to onboarding
- [ ] Tests use Story #010 shared fixtures/utilities
- [ ] `npm run test:unit` passes

# Technical Context

## Current State
- Step logic and orchestration: `/signup/app/routes/onboarding/flow/steps.ts`
- Onboarding page checkout path: `/signup/app/routes/onboarding/page.tsx`
- Success page verification logic: `/signup/app/routes/success/page.tsx`
- Cancel page: `/signup/app/routes/cancel/page.tsx`

## Proposed Changes
- Add new page-level onboarding completion tests
- Add success/cancel route tests with mocked auth/api behaviors
- Keep all network calls mocked

## File Locations
- New/updated tests:
  - `/signup/tests/unit/onboarding/page.steps-6-7-billing.test.tsx` (new)
  - `/signup/tests/unit/onboarding/steps.test.ts` (update for step-6/7 details)
  - `/signup/tests/unit/success/page.test.tsx` (new)
  - `/signup/tests/unit/cancel/page.test.tsx` (new)

# Open Questions

- [x] Polling assertions with fake timers or extraction? **Use fake timers for now; do not refactor production code in this story.**
- [x] Where to assert redirects? **At page-level tests where `window.location.assign` and router redirects occur.**

# Dependencies

- Parent: Story #003
- Foundation: Story #010
- Related: Story #011

# Implementation Tasks

## Task 1: Extend step-6/7 unit coverage (35 min)
- Update `/signup/tests/unit/onboarding/steps.test.ts`:
  - assert step-6 state transitions for match loading/success/empty/error
  - assert step-7 completion transition payload
- Verification: step tests pass with deterministic fixtures.

## Task 2: Add onboarding completion page tests (45 min)
- Create `/signup/tests/unit/onboarding/page.steps-6-7-billing.test.tsx`.
- Cover checkout branches in `/billing/checkout`:
  - success -> `window.location.assign(url)`
  - `already_subscribed` -> router push `/dashboard`
  - generic failure -> fallback error assistant message
- Verification: branch-specific assertions pass.

## Task 3: Add success page verification tests (45 min)
- Create `/signup/tests/unit/success/page.test.tsx`.
- Cover:
  - session id present -> confirm endpoint used
  - no session id -> status endpoint used
  - active/trialing -> redirect to `/dashboard`
  - non-active/error -> billing error shown
- Verification: route behavior assertions pass.

## Task 4: Add cancel page test (20 min)
- Create `/signup/tests/unit/cancel/page.test.tsx`.
- Assert rendered cancellation message and link to `/onboarding`.
- Verification: test passes and remains snapshot-free.

## Task 5: Regression pass (20 min)
- Run `npm run test:unit` and fix timing/mocking issues.

# Notes

Do not include Playwright or real Stripe calls. Keep this story FE Vitest-only.
