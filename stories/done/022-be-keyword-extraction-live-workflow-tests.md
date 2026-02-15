---
id: 022
title: Backend Keyword Extraction Live Workflow Tests
status: done
priority: medium
labels: [testing, backend, llm, keyword-extraction, workflows]
estimate: medium
created: 2026-02-12
updated: 2026-02-12
---

# User Story

As a backend developer,
I want live keyword extraction workflow tests against a dedicated workflow database on local Postgres,
So that keyword extraction state transitions and DB writes are validated end-to-end.

# Problem Statement

Keyword extraction introduces LLM-dependent writes and retry/failure semantics. Existing tests validate core logic but do not fully prove production-like DB transitions under real workflow execution conditions.

# Proposed Solution (High-Level)

Add workflow-live tests for keyword extraction flows that seed extraction candidates, execute extraction runs, and assert success/failure persistence directly in SQL.

# Acceptance Criteria

- [ ] Live workflow tests cover extraction task/flow execution with local Postgres
- [ ] Tests run only against `tenderbot_workflow_test`, not `tenderbot` or `tenderbot_test`
- [ ] Workflow-live command automatically resets `tenderbot_workflow_test` before extraction tests run
- [ ] Suite bootstrap asserts `SELECT current_database()` equals `tenderbot_workflow_test`
- [ ] Setup seeds tenders eligible for extraction and isolates records by run ID
- [ ] Success path verifies `extracted_keywords` and extraction metadata columns are persisted correctly
- [ ] Failure path verifies error metadata/state is persisted for failed extractions
- [ ] Dry-run behavior is asserted to confirm no write side effects
- [ ] Tests are in dedicated workflow-live lane and do not impact cheap test commands

# Technical Context

## Current State
- Extraction flow exists at `/backend/tenderbot/tasks/flows/keyword_extraction.py`
- Repository methods support claim/success/failure transitions in tender data layer
- Unit coverage exists for flow behavior and batch client logic

## Proposed Changes
- Add workflow-live extraction module with setup/teardown helpers
- Add workflow DB guardrails to prevent execution against manual and integration DBs
- Execute extraction in controlled batches and validate SQL-level outcomes
- Assert run summaries align with persisted state

## File Locations
- Flow/task implementation: `/backend/tenderbot/tasks/flows/keyword_extraction.py`
- Workflow tests: `/backend/tests/workflow_live/test_keyword_extraction_live.py`
- Shared SQL assertions/helpers: `/backend/tests/helpers/`

# Open Questions

- [x] Should tests enforce exact keyword strings from LLM outputs? **No. Assert non-empty normalized keywords and state transitions.**
- [x] Should failure-path testing rely on real provider failures? **No. Use controlled trigger/input to validate failure persistence deterministically.**

# Dependencies

- Requires: Story #019
- Related LLM workflow coverage: Story #021

# Implementation Tasks

## Task 1: Seed extraction candidates and run-scoped fixtures (35 min)
- Insert tenders with extraction-pending state for test execution.
- Assert DB identity and DSN separation before seeding fixtures.
- Verification: candidates are claimable by extraction task.

## Task 2: Add success-path live extraction test (45 min)
- Execute extraction and assert summary + DB success writes.
- Verification: keywords and metadata columns updated as expected.

## Task 3: Add failure-path persistence test (40 min)
- Trigger controlled extraction failure and assert DB failure fields.
- Verification: failure count and error storage align with summary.

## Task 4: Add dry-run non-persistence assertion (20 min)
- Execute dry-run and verify candidate state remains unchanged.
- Verification: no write side effects detected via SQL.

# Notes

This story focuses on extraction workflow correctness and database outcomes, not prompt quality tuning.
