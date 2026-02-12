---
id: 014
title: Backend Onboarding API Contract Tests
status: done
priority: high
labels: [testing, backend, api, contract]
estimate: medium
created: 2026-02-11
updated: 2026-02-12
---

# User Story

As a frontend and backend developer,
I want stable onboarding API contract tests,
So that FE onboarding behavior does not break when backend responses evolve.

# Problem Statement

Backend has strong unit coverage, but FE-critical onboarding contracts are spread across multiple test files and not tracked as one implementation target. We need explicit contract assertions for the onboarding API chain.

Contract chain in scope:
- `POST /suggest/categories`
- `POST /suggest/keywords`
- `POST /customers/identify`
- `POST /customers/{id}/alert-profiles`
- `POST /alert-profiles/{id}/matches?mode=relaxed`

# Proposed Solution (High-Level)

Add/organize backend API-level tests that assert request and response contracts FE depends on, including success and error semantics.

# Acceptance Criteria

- [x] Contract tests assert expected request/response shapes for all endpoints in scope
- [x] Suggestion endpoints validate fallback behavior when LLM payloads are invalid
- [x] Alert profile and matches endpoints validate FE-consumed fields and types
- [x] Error payload semantics are asserted for representative failure paths
- [x] Tests run in existing backend test workflow (`mise run test`, `mise run test-integration` where relevant)

# Technical Context

## Current State
- Existing suggestions API tests: `/backend/tests/api/test_suggestions.py`
- Existing matches endpoint tests: `/backend/tests/api/test_tender_match_actions.py`
- Existing router/unit tests for related endpoints under `/backend/tests/unit/tenderbot/api/`

## Proposed Changes
- Add a dedicated onboarding contract test module (or clearly grouped block in existing files)
- Reuse shared auth/app fixtures from `/backend/tests/conftest.py`
- Assert compatibility with FE expectations documented in Stories #011 and #012

## File Locations
- Primary tests:
  - `/backend/tests/api/test_suggestions.py`
  - `/backend/tests/api/test_tender_match_actions.py`
- New contract test module:
  - `/backend/tests/api/test_onboarding_contracts.py` (recommended)

# Open Questions

- [x] Keep this as API contract tests vs deeper domain tests? **API contract tests only.**
- [x] Include real external integrations? **No, keep deterministic stubs/mocks.**

# Dependencies

- Parent epic: Story #003
- Related FE consumers: Story #011, Story #012

# Implementation Tasks

## Task 1: Define onboarding contract matrix (30 min)
- Create endpoint-by-endpoint matrix of required request/response keys and error payloads.
- Verification: matrix is reflected in test names and assertions.

## Task 2: Add suggestion endpoint contract assertions (40 min)
- Strengthen `/suggest/categories` and `/suggest/keywords` API tests for shape/type guarantees.
- Verification: tests fail on missing fields/changed schema.

## Task 3: Add identify/profile/matches chain contract assertions (50 min)
- Add tests for customer identify -> profile create -> relaxed matches flow with FE-compatible fields.
- Verification: expected keys and value types asserted end-to-end at API boundary.

## Task 4: Add representative failure contract tests (35 min)
- Assert status code and `detail` payload format for common failures (validation/domain errors).
- Verification: FE can map backend error responses without schema ambiguity.

## Task 5: Backend test run and stabilization (25 min)
- Run `mise run test` and address flaky assumptions.

# Notes

This story is backend-only and contract-focused. It should not introduce FE test changes.
