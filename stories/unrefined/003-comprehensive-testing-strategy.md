---
id: 003
title: Comprehensive Testing for Onboarding and Dashboard
status: unrefined
priority: high
labels: [testing, frontend, backend, integration]
estimate: unknown
created: 2026-02-07
updated: 2026-02-07
---

# User Story

As a developer,
I want comprehensive test coverage for onboarding and dashboard flows,
So that we can deploy changes confidently without breaking critical paths.

# Problem Statement

We lack adequate frontend, integration, and end-to-end tests. Specifically:

**Coverage Gaps:**
- Onboarding flow (7 steps)
- Dashboard functionality (5 tabs)
- Authentication flows

**Testing Obstacles:**

1. **LLM Dependencies in Onboarding**
   - Categories step depends on `POST /suggest/categories`
   - Keywords step depends on `POST /suggest/keywords`
   - LLM responses are unpredictable and expensive
   - Can't reliably test with real LLM calls

2. **Authentication Gates**
   - Login required after keywords step in onboarding
   - Entire dashboard requires authentication
   - Need automated testing without manual login

3. **Stripe Checkout**
   - Must test checkout flow redirects correctly
   - Need to verify success/cancel page handling
   - Can't use real payments in tests

# Proposed Solution (High-Level)

**Multi-Layer Testing Strategy:**

1. **Unit Tests** - Individual components with mocked dependencies
2. **Integration Tests** - Frontend + Backend with test doubles for LLM/Stripe/Auth
3. **E2E Tests** - Full flow tests against staging environment

**Key Requirements:**
- Mock LLM responses for predictable test data
- Mock Auth0 authentication for test users
- Mock Stripe checkout for payment flow tests
- Separate frontend tests from backend API tests
- Test backend endpoints independently

# Acceptance Criteria

- [ ] Onboarding flow fully tested (all 7 steps)
- [ ] Dashboard tabs fully tested (all 5 tabs)
- [ ] Authentication flows tested
- [ ] Stripe checkout flow tested
- [ ] Tests run fast locally (no real API calls)
- [ ] Integration tests catch frontend-backend issues
- [ ] Test coverage >80% for critical paths

# Technical Context

## Current State
- Some Playwright E2E tests exist
- Some Vitest unit tests exist
- No comprehensive integration test suite
- No mocking strategy for LLM/Auth/Stripe

## Proposed Changes
- Set up test doubles/mocks for external services
- Create test fixtures for LLM responses
- Implement Auth0 test user or mock auth tokens
- Add Stripe test mode checkout
- Write comprehensive test suites

## File Locations
- Frontend tests: `/signup/__tests__/`
- Backend tests: `/backend/tests/`
- Playwright config: `/signup/playwright.config.ts`
- Vitest config: `/signup/vitest.config.ts`

# Open Questions

- [ ] Should we mock LLM at API boundary or service layer?
- [ ] How to generate Auth0 test tokens without manual login?
- [ ] Do we need a test mode flag in backend API?
- [ ] What's the right balance between mocked vs real integration tests?
- [ ] How to structure test data fixtures?

# Dependencies

- Story #004 (Staging environment needed for E2E tests)

# Notes

This is a large effort that may need to be broken into multiple stories:
- Frontend unit/integration tests
- Backend API tests
- E2E test infrastructure
- Test doubles/mocking strategy
