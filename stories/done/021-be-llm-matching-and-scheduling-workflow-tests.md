---
id: 021
title: Backend LLM Matching and Scheduling Workflow Tests
status: done
priority: high
labels: [testing, backend, llm, matching, workflows]
estimate: large
created: 2026-02-12
updated: 2026-02-12
---

# User Story

As a backend developer,
I want live LLM workflow tests for matching and scheduling jobs against a dedicated workflow database on local Postgres,
So that we can trust end-to-end match generation behavior and downstream persistence.

# Problem Statement

Matching and scheduling are central backend workflows with multiple side effects (candidate selection, LLM refinement, match persistence, delivery records, profile timestamps). Unit tests validate components but do not fully validate production-like orchestration with real database state.

# Proposed Solution (High-Level)

Add workflow-live tests that seed realistic alert profiles and tenders, run matching and scheduling flows, and verify correctness using SQL assertions for all side-effect tables.

# Acceptance Criteria

- [ ] Tests cover `generate_matches_task` and scheduler orchestration paths with local Postgres
- [ ] Tests run only against `tenderbot_workflow_test`, never `tenderbot` or `tenderbot_test`
- [ ] Workflow-live command automatically resets `tenderbot_workflow_test` before test execution
- [ ] Suite bootstrap asserts `SELECT current_database()` equals `tenderbot_workflow_test`
- [ ] Test setup creates multiple alert profiles (different cpv/keyword/region combinations) and deterministic tender fixtures
- [ ] LLM-enabled path is exercised in this suite (with explicit environment gating)
- [ ] Post-run SQL assertions validate expected writes in `tender_matches`, `delivery_history`, and alert profile delivery timestamps
- [ ] Rerun behavior validates dedupe/idempotency expectations (no duplicate persisted matches for same profile/tender)
- [ ] Tests remain isolated via run-scoped fixture records with reliable teardown

# Technical Context

## Current State
- Matching flow and tasks live in `/backend/tenderbot/tasks/flows/matching_flow.py`
- Scheduling flow lives in `/backend/tenderbot/tasks/flows/schedule_alerts.py`
- Match generation logic is covered mostly by unit tests and contract tests

## Proposed Changes
- Add workflow-live modules for single-profile and scheduler-multi-profile runs
- Add workflow DB guards to prevent accidental execution against manual and integration databases
- Seed DB with controlled fixture data for candidate and non-candidate tenders
- Add SQL assertions for side effects and dedupe behavior

## File Locations
- Matching flow: `/backend/tenderbot/tasks/flows/matching_flow.py`
- Scheduler flow: `/backend/tenderbot/tasks/flows/schedule_alerts.py`
- Workflow tests: `/backend/tests/workflow_live/test_matching_and_scheduler_live.py`
- Shared DB fixture helpers: `/backend/tests/helpers/`

# Open Questions

- [x] Should this suite send real emails? **No. Use delivery mode that records delivery state without external email side effects.**
- [x] Should scheduler tests assert exact LLM output text? **No. Assert structural/data invariants and confidence boundaries, not brittle phrasing.**

# Dependencies

- Requires: Story #019
- Depends on fixture capabilities from: Story #017
- Complements: Story #022

# Implementation Tasks

## Task 1: Build profile/tender fixture seeding for matching scenarios (50 min)
- Seed positive and negative candidate cases across multiple profiles.
- Add startup DB identity check (`current_database()`) and fail on mismatch.
- Verification: deterministic candidate selection baseline is reproducible.

## Task 2: Add generate-matches live workflow tests (60 min)
- Execute matching task and validate persisted match rows with SQL.
- Verification: persisted rows and key fields match expected invariants.

## Task 3: Add schedule-alerts orchestration test (50 min)
- Execute scheduler flow and validate multi-profile processing outcomes.
- Verification: due profiles processed and summary metrics align with DB state.

## Task 4: Add idempotency/dedupe rerun assertions (35 min)
- Rerun matching with same fixture set and confirm no duplicate inserts.
- Verification: row counts and uniqueness behavior remain stable.

# Notes

This story targets LLM-backed job workflows. It intentionally avoids backfill coverage.
