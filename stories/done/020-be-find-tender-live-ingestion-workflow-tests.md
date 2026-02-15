---
id: 020
title: Backend Find a Tender Live Ingestion Workflow Tests
status: done
priority: high
labels: [testing, backend, ingestion, integration, workflows]
estimate: medium
created: 2026-02-12
updated: 2026-02-12
---

# User Story

As a backend developer,
I want ingestion workflow tests that hit a dedicated workflow database on local Postgres and the live Find a Tender API,
So that we can validate real ingestion behavior and persisted data correctness.

# Problem Statement

The ingestion path is critical and currently covered mainly by unit/deterministic integration tests. We need live workflow coverage to validate parser behavior, external API contract assumptions, and persistence effects in real DB state.

# Proposed Solution (High-Level)

Add live ingestion workflow tests that run against local Postgres and call Find a Tender APIs through the real client. Verify outcomes using SQL assertions after run completion.

# Acceptance Criteria

- [ ] Live ingestion tests run through `run_ingest` path using real Find a Tender client and `tenderbot_workflow_test`
- [ ] Workflow-live command automatically resets `tenderbot_workflow_test` before ingestion tests run
- [ ] Preflight fails if workflow DSN matches `TENDERBOT_DB_DSN` or the integration-test DSN
- [ ] Tests assert runtime DB identity with `SELECT current_database()` and require `tenderbot_workflow_test`
- [ ] Tests are tagged for the dedicated workflow-live lane and are excluded from unit and cheap integration loops
- [ ] Setup creates run-scoped fixtures and captures baseline row counts before execution
- [ ] Post-run SQL assertions verify insert/update outcomes and key field correctness in `tenders` and ingestion state tables
- [ ] Tests include resilient behavior for external instability (clear skip/retry strategy for transient API failures)
- [ ] Story explicitly excludes backfill workflow coverage

# Technical Context

## Current State
- Ingestion logic exists in `/backend/tenderbot/jobs/run_ingest.py` and service layer ingestion functions
- Find a Tender client exists in `/backend/tenderbot/services/find_tender_client.py`
- Existing integration ingestion tests rely on fixtures and in-memory repos rather than live API

## Proposed Changes
- Add workflow-live test module for incremental ingestion
- Enforce workflow DB isolation from manual and integration DBs in test bootstrap
- Use DB helper utilities for pre/post SQL assertions
- Assert ingestion state transitions (`window_start`, `window_end`, cursor/last_success markers) and tender row integrity

## File Locations
- Job entrypoint: `/backend/tenderbot/jobs/run_ingest.py`
- External client: `/backend/tenderbot/services/find_tender_client.py`
- Workflow tests: `/backend/tests/workflow_live/test_find_tender_ingestion_live.py`
- SQL assertion helpers: `/backend/tests/helpers/`

# Open Questions

- [x] Should assertions lock exact tender counts from live API? **No. Use bounded/invariant assertions instead of brittle absolute counts.**
- [x] Should failed API reachability fail suite or skip this module? **Skip module with explicit reason when service unavailable; fail when local prerequisites are invalid.**

# Dependencies

- Requires: Story #019
- Related: Story #017

# Implementation Tasks

## Task 1: Build ingestion live test setup and preflight (40 min)
- Prepare run-scoped identifiers and baseline DB snapshots.
- Assert DSN separation and runtime DB name before job execution.
- Verification: test can run repeatedly without polluting unrelated rows.

## Task 2: Execute incremental ingestion and capture outputs (45 min)
- Run ingestion through production path with real API client.
- Verification: execution completes with valid summary object and exit semantics.

## Task 3: Add SQL-based correctness assertions (50 min)
- Verify new/updated row invariants and ingestion state updates.
- Verification: assertions fail on schema or write-path regressions.

## Task 4: Add resilience/skip behavior for transient external failures (25 min)
- Handle upstream availability/rate-limit edge cases in a controlled way.
- Verification: flaky external states are reported clearly, not as opaque failures.

# Notes

This story covers incremental ingestion only. Backfill intentionally remains out of scope.
