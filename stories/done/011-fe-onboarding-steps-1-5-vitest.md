---
id: 011
title: Vitest Coverage for Onboarding Steps 1-5
status: done
priority: high
labels: [testing, frontend, vitest, onboarding]
estimate: medium
created: 2026-02-11
updated: 2026-02-11
---

# User Story

As a developer,
I want robust Vitest coverage for onboarding steps 1-5,
So that early onboarding flow regressions are caught before they impact conversion.

# Problem Statement

Existing onboarding tests validate step classes but do not sufficiently cover page-level orchestration and continue-button gating in the chat flow.

Steps 1-5 drive most user input and suggestion behavior:
- business type
- categories
- region
- keywords
- frequency

# Proposed Solution (High-Level)

Add focused tests for both step logic and page-level interactions up to the tender preview boundary.

Coverage focus:
1. Input/selection gating for step progression
2. Suggestion fetch success/failure behavior for categories and keywords
3. Context updates reflected in UI behavior (continue enabled/disabled)
4. Resume payload persistence when unauthenticated user reaches preview boundary

# Acceptance Criteria

- [ ] Tests cover happy path progression through steps 1-5
- [ ] Continue button enable/disable rules are asserted for each step
- [ ] Category suggestion success and fallback behavior are tested
- [ ] Keyword suggestion success and error fallback behavior are tested
- [ ] Resume payload persistence is tested before auth redirect boundary
- [ ] Tests use Story #010 shared fixtures/utilities
- [ ] `npm run test:unit` passes

# Technical Context

## Current State
- Onboarding page orchestration: `/signup/app/routes/onboarding/page.tsx`
- Step logic: `/signup/app/routes/onboarding/flow/steps.ts`
- Flow/context model: `/signup/app/routes/onboarding/flow/core.ts`, `/signup/app/routes/onboarding/flow/onboardingFlow.ts`
- Existing tests: `/signup/tests/unit/onboarding/steps.test.ts`, `/signup/tests/unit/onboarding/flowCore.test.ts`

## Proposed Changes
- Extend onboarding unit coverage with page-level tests for steps 1-5 behavior
- Keep tests deterministic with mocked auth/api responses
- Avoid checkout and dashboard assertions (handled by later stories)

## File Locations
- New/updated tests:
  - `/signup/tests/unit/onboarding/steps.test.ts`
  - `/signup/tests/unit/onboarding/page.steps-1-5.test.tsx` (new)

# Open Questions

- [x] Component-level vs flow-level balance? **Use both: keep step unit tests and add page orchestration tests.**
- [x] Scope boundary for this story? **Stop at frequency completion; tender preview and billing are Story #012.**

# Dependencies

- Parent: Story #003
- Foundation: Story #010

# Implementation Tasks

## Task 1: Add page test harness for onboarding (35 min)
- Create `/signup/tests/unit/onboarding/page.steps-1-5.test.tsx`.
- Mock `useAuth` as authenticated and `apiFetch`/`fetch` responses as needed.
- Render onboarding page route component and expose helper interactions.
- Verification: test file runs independently with Vitest.

## Task 2: Assert step gating for steps 2-5 (35 min)
- Add tests for `isContinueEnabled` behavior via UI state:
  - categories requires at least one category and CPV mapping
  - region requires at least one region
  - keywords requires at least one keyword
  - frequency requires one selected frequency
- Verification: assertions confirm button disabled/enabled transitions.

## Task 3: Cover category suggestion fetch paths (30 min)
- In `/signup/tests/unit/onboarding/steps.test.ts`, ensure:
  - successful `/suggest/categories` response updates options/CPV/recommended keywords
  - failed response uses defaults and sets error state
- Verification: state assertions for both paths.

## Task 4: Cover keyword suggestion fetch paths (30 min)
- Add tests for `KeywordsStep.onEnter`:
  - successful `/suggest/keywords` adds normalized recommendations
  - failure sets `keywordError` and marks fetch completed
- Verification: expected context changes asserted.

## Task 5: Cover resume payload persistence boundary (30 min)
- In page-level test, simulate unauthenticated state after step-5-ready context.
- Assert onboarding resume payload is saved to storage key `tb_onboarding_state_v3`.
- Verification: storage payload includes context and `stepId: tender_matches`.

## Task 6: Regression pass (20 min)
- Run `npm run test:unit`.
- Fix flaky timing with fake timers where required.

# Notes

This story is intentionally limited to onboarding steps 1-5. Do not add checkout or success-page behavior here.
