---
id: 017
title: Backend Test Fixtures and Integration Harness Hardening
status: refined
priority: medium
labels: [testing, backend, fixtures, reliability]
estimate: medium
created: 2026-02-11
updated: 2026-02-11
---

# User Story

As a backend developer,
I want shared test fixtures and harness helpers,
So that API contract and integration tests are faster to write and less flaky.

# Problem Statement

Backend tests already cover many features, but repeated fixture setup across API/integration suites increases maintenance cost and inconsistency risk.

We need a lightweight hardening pass before scaling contract test coverage.

# Proposed Solution (High-Level)

Introduce reusable fixture factories and helper utilities for customer/profile/billing/match/history scenarios used by backend contract tests.

# Acceptance Criteria

- [ ] Shared test factories exist for common entities (customer, alert profile, billing subscription, tender match, delivery history)
- [ ] At least three existing backend test modules are migrated to shared fixtures
- [ ] Test helpers reduce duplicated setup logic without changing behavior
- [ ] No regression in backend test results (`mise run test`)

# Technical Context

## Current State
- Shared fixtures currently concentrated in `/backend/tests/conftest.py`
- Many suites contain local fake classes/factory helpers
- New contract stories (#014-#016) will increase fixture usage pressure

## Proposed Changes
- Add focused helper modules under `/backend/tests/helpers/` (or equivalent existing pattern)
- Migrate selected API suites first, then wider adoption incrementally

## File Locations
- Existing fixture anchor: `/backend/tests/conftest.py`
- Proposed helper modules:
  - `/backend/tests/helpers/factories.py`
  - `/backend/tests/helpers/api_contract_builders.py`

# Open Questions

- [x] Big-bang migration vs incremental? **Incremental migration for selected suites first.**
- [x] Should this include production code refactors? **No, test-layer refactor only.**

# Dependencies

- Parent epic: Story #003
- Enables: Story #014, Story #015, Story #016

# Implementation Tasks

## Task 1: Identify top duplicated fixture patterns (30 min)
- Inventory repeated setup in onboarding, billing, and dashboard API tests.
- Verification: list of reusable patterns prepared.

## Task 2: Implement shared factories/helpers (50 min)
- Add helper modules for common entity and response payload creation.
- Verification: helpers are typed and imported in at least one suite.

## Task 3: Migrate onboarding contract tests to helpers (35 min)
- Update one onboarding-related API test module to use shared helpers.
- Verification: no behavior change, reduced local boilerplate.

## Task 4: Migrate billing contract tests to helpers (35 min)
- Update one billing test module to shared fixtures.
- Verification: existing assertions remain intact.

## Task 5: Migrate dashboard contract tests to helpers and run tests (40 min)
- Update one dashboard/delivery-history module and run `mise run test`.
- Verification: suite passes; duplication measurably reduced.

# Notes

This story improves test maintainability and reliability; it does not define new product behavior.
