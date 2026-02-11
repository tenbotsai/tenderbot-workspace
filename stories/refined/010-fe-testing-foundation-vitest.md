---
id: 010
title: Frontend Testing Foundation with Vitest
status: refined
priority: high
labels: [testing, frontend, vitest]
estimate: medium
created: 2026-02-11
updated: 2026-02-11
---

# User Story

As a developer,
I want shared Vitest test utilities and deterministic fixtures,
So that onboarding and dashboard tests are fast, consistent, and easy to extend.

# Problem Statement

Current FE tests use inconsistent setup patterns (`vi.mock`, `fetch` stubs, inline fixtures). This creates duplication and makes new coverage stories slower to implement.

We need one reusable test foundation before adding broader onboarding and dashboard coverage.

# Proposed Solution (High-Level)

Create a shared FE test foundation under `signup/tests/unit/` and apply it to at least one onboarding test and one dashboard test.

Foundation scope:
1. Shared auth mocks for authenticated/unauthenticated states
2. Shared API response builders/fixtures
3. Shared render/setup helpers for page-level tests
4. Shared redirect and browser API stubs

# Acceptance Criteria

- [ ] Shared test helpers exist for auth mocking and API fetch mocking
- [ ] Deterministic fixtures exist for onboarding suggestions, match preview, billing checkout, and dashboard data
- [ ] At least one onboarding suite and one dashboard suite consume shared helpers
- [ ] No FE tests in this phase require real Auth0/Stripe/backend calls
- [ ] `npm run test:unit` passes after foundation changes

# Technical Context

## Current State
- Vitest config: `/signup/vitest.config.ts`
- Vitest setup: `/signup/vitest.setup.ts`
- Existing onboarding tests: `/signup/tests/unit/onboarding/steps.test.ts`, `/signup/tests/unit/onboarding/flowCore.test.ts`
- Existing dashboard tests: `/signup/tests/unit/dashboard/page.test.tsx`
- Auth hook/provider used by pages: `/signup/app/components/auth.tsx`
- API wrapper used by pages: `/signup/app/lib/api.ts`

## Proposed Changes
- Add shared helpers under `/signup/tests/unit/test-utils/`
- Add fixtures under `/signup/tests/unit/fixtures/`
- Refactor existing tests to consume helpers in a minimal, safe pass

## File Locations
- New helper directory: `/signup/tests/unit/test-utils/`
- New fixtures directory: `/signup/tests/unit/fixtures/`
- Initial adoptions:
  - `/signup/tests/unit/onboarding/steps.test.ts`
  - `/signup/tests/unit/dashboard/page.test.tsx`

# Open Questions

- [x] Use a new mocking library (for example MSW) now? **No, keep existing Vitest mocking approach.**
- [x] Fixture location strategy? **Centralized under `/signup/tests/unit/fixtures/` with feature-specific files.**
- [x] Single setup file or many? **Keep `vitest.setup.ts` as global base, use per-suite helpers for specifics.**

# Dependencies

- Parent: Story #003

# Implementation Tasks

## Task 1: Add auth mock helper module (30 min)
- Create `/signup/tests/unit/test-utils/mockAuth.ts` with helpers:
  - `mockAuthenticatedUser()`
  - `mockUnauthenticatedUser()`
  - `resetAuthMock()`
- Must mock `useAuth` from `/signup/app/components/auth.tsx`.
- Verification: one existing test imports and uses these helpers.

## Task 2: Add API mock helper module (30 min)
- Create `/signup/tests/unit/test-utils/mockApiFetch.ts` with:
  - success/error response builders
  - queueable mock response helper for multi-call flows
  - reset helper
- Target `apiFetch` from `/signup/app/lib/api.ts`.
- Verification: one onboarding and one dashboard test use helper.

## Task 3: Add fixture modules (40 min)
- Create:
  - `/signup/tests/unit/fixtures/onboardingFixtures.ts`
  - `/signup/tests/unit/fixtures/dashboardFixtures.ts`
  - `/signup/tests/unit/fixtures/billingFixtures.ts`
- Include deterministic payloads for `/suggest/categories`, `/suggest/keywords`, `/alert-profiles/*/matches`, `/billing/checkout`, `/delivery-history`.
- Verification: fixtures referenced by tests, no inline ad-hoc JSON in updated suites.

## Task 4: Add browser stub helper (25 min)
- Create `/signup/tests/unit/test-utils/browserStubs.ts` for:
  - `window.location.assign` spy setup/reset
  - `sessionStorage`/`localStorage` seed helpers
  - fake timer helper for redirect delays
- Verification: used in at least one onboarding billing test.

## Task 5: Refactor baseline suites to shared helpers (35 min)
- Update `/signup/tests/unit/onboarding/steps.test.ts` and `/signup/tests/unit/dashboard/page.test.tsx` to use new test-utils/fixtures.
- Verification: `npm run test:unit` passes.

# Notes

Keep this story narrowly focused on shared test infrastructure. Do not expand coverage breadth here; that is handled by Stories #011-#013.
