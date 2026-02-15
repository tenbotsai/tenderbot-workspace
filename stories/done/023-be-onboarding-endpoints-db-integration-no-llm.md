---
id: 023
title: Backend Onboarding Endpoints DB Integration Tests Without LLM
status: done
priority: high
labels: [testing, backend, api, onboarding, integration]
estimate: medium
created: 2026-02-12
updated: 2026-02-12
---

# User Story

As a frontend and backend developer,
I want onboarding endpoint integration tests against a dedicated workflow database on local Postgres without LLM calls,
So that onboarding API and persistence behavior remain stable independently of LLM variability.

# Problem Statement

Onboarding API contract tests exist, but we need a dedicated DB-backed integration lane that verifies endpoint behavior and persistence changes while explicitly avoiding live LLM dependencies.

# Proposed Solution (High-Level)

Add onboarding API integration tests using real repositories and local Postgres. Stub/disable LLM paths where needed and verify endpoint responses plus DB state transitions with SQL checks.

# Acceptance Criteria

- [ ] Tests cover onboarding chain endpoints using real DB-backed app dependencies
- [ ] Tests run in workflow-live lane against `tenderbot_workflow_test`, never `tenderbot`
- [ ] Workflow-live command automatically resets `tenderbot_workflow_test` before onboarding tests run
- [ ] Suite bootstrap verifies `SELECT current_database()` equals `tenderbot_workflow_test`
- [ ] Endpoints in scope include at minimum:
  - `POST /customers/identify`
  - `POST /customers/{id}/alert-profiles`
  - `POST /alert-profiles/{id}/matches?mode=relaxed`
  - `POST /suggest/categories`
  - `POST /suggest/keywords`
- [ ] LLM is not called in this suite; suggestion and matching behavior uses fallback/stubbed deterministic responses
- [ ] SQL assertions verify created/updated records for customers, alert profiles, and any generated matches or related side effects
- [ ] Error-path semantics remain validated for representative invalid payloads
- [ ] Suite is separated from unit tests and runnable through dedicated non-unit integration command(s)

# Technical Context

## Current State
- Onboarding contract tests exist in `/backend/tests/api/test_onboarding_contracts.py`
- Test app fixtures often use in-memory stubs in `/backend/tests/conftest.py`
- Router paths involved are in customers, alert profiles, tender matches, and suggestions modules

## Proposed Changes
- Add DB-backed onboarding integration module under workflow/integration lane
- Add workflow DB guardrails that fail if DSN targets manual (`tenderbot`) or integration (`tenderbot_test`) databases
- Wire deterministic LLM overrides at dependency boundary
- Add explicit SQL validation helpers for onboarding entities

## File Locations
- Existing contract tests: `/backend/tests/api/test_onboarding_contracts.py`
- API routers:
  - `/backend/tenderbot/api/routers/customers.py`
  - `/backend/tenderbot/api/alert_profiles/router.py`
  - `/backend/tenderbot/api/tender_matches/router.py`
  - `/backend/tenderbot/api/suggestions/router.py`
- New DB integration tests: `/backend/tests/workflow_live/test_onboarding_db_integration_no_llm.py`

# Open Questions

- [x] Should onboarding DB integration replace existing contract tests? **No. Keep both; contract tests remain fast and deterministic.**
- [x] Should suggestion endpoints assert exact category/keyword values? **No. Assert response shape/source and DB side effects where applicable.**

# Dependencies

- Requires: Story #019
- Related: Story #014 (API contract baseline)

# Implementation Tasks

## Task 1: Build DB-backed onboarding test app fixtures (40 min)
- Use real DB repos with isolated test data and auth context.
- Verification: endpoints operate through persistence layer, not in-memory repos.

## Task 2: Add identify + alert-profile persistence tests (45 min)
- Execute onboarding create/update path and assert SQL state.
- Verification: customer/profile records match API responses.

## Task 3: Add relaxed matches + suggestion endpoint tests with no LLM calls (50 min)
- Ensure deterministic fallback/stub behavior for suggestion and relaxed match flow.
- Verification: no external LLM call required; responses remain contract-safe.

## Task 4: Add representative error-path assertions (25 min)
- Validate invalid payload and not-found semantics.
- Verification: status/detail payload contract remains consistent.

# Notes

This story is onboarding-focused and explicitly excludes live LLM behavior to keep failures actionable and deterministic.
