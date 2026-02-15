---
id: 019
title: Backend Live Workflow Test Harness and Command
status: done
priority: high
labels: [testing, backend, integration, workflows]
estimate: medium
created: 2026-02-12
updated: 2026-02-12
---

# User Story

As a backend developer,
I want a dedicated live-workflow test harness and command,
So that expensive end-to-end tests remain isolated from fast unit and contract test loops.

# Problem Statement

Current backend tests are split into unit and integration markers, but we need an explicit lane for expensive workflow tests that use the same local Postgres instance with a separate workflow database and external APIs. Without this separation, developers either avoid useful workflow coverage or run costly tests too often.

# Proposed Solution (High-Level)

Create a dedicated test category for live workflow tests with a separate command, marker, and fixture utilities. This suite should be opt-in, deterministic where possible, and designed for local and scheduled CI runs.

# Acceptance Criteria

- [ ] A new pytest marker exists for live workflow tests and is excluded from default `mise run test`
- [ ] A dedicated command exists (for example `mise run test-workflow-live`) to run only this suite
- [ ] The workflow-live command automatically resets `tenderbot_workflow_test` (drop/create/migrate) before test execution
- [ ] Workflow-live tests fail fast if configured DSN points to `tenderbot` or `tenderbot_test`
- [ ] Workflow-live preflight verifies `SELECT current_database()` equals `tenderbot_workflow_test`
- [ ] Test preflight validates required env vars and external dependency reachability with clear skip/fail behavior
- [ ] Shared fixture utilities create and clean test customers, alert profiles, and related records using deterministic run IDs
- [ ] Developer docs describe when to run this suite and expected runtime/cost characteristics

# Technical Context

## Current State
- Unit tests run via `mise run test` and default pytest config excludes `integration` only
- Integration tests run via `mise run test-integration`
- Existing integration tests are mostly deterministic and do not represent full live LLM + external API workflows
- Integration tests currently target `tenderbot_test`; manual local testing typically targets `tenderbot`

## Proposed Changes
- Add a dedicated marker (for example `workflow_live`) and update pytest marker configuration
- Add a new mise task script that runs only live workflow tests (for example `uv run pytest -m workflow_live`)
- Route workflow-live tests to `tenderbot_workflow_test` via a dedicated workflow DB DSN with no fallback to `TENDERBOT_DB_DSN`
- Ensure `mise run test-workflow-live` always performs automated reset of `tenderbot_workflow_test`
- Add shared test helpers for setup/teardown and DB assertions using `asyncpg`
- Add preflight utility that validates env and connectivity before test execution

## File Locations
- Pytest config: `/backend/pyproject.toml`
- Mise tasks: `/backend/mise.toml`, `/backend/mise-tasks/test/`
- Shared helpers: `/backend/tests/helpers/`
- Live suite root: `/backend/tests/workflow_live/`
- Documentation: `/backend/README.md`

# Open Questions

- [x] Should live workflow tests run on every PR? **No. Keep them opt-in locally and scheduled/manual in CI.**
- [x] Should preflight hard-fail or skip when env is incomplete? **Fail with actionable message for explicit workflow-live runs; skip only when explicitly configured to do so.**

# Dependencies

- Builds on: Story #017 (fixture/harness hardening)
- Enables: Story #020, Story #021, Story #022, Story #023

# Implementation Tasks

## Task 1: Define marker and command wiring (30 min)
- Add new marker and command path for live workflow tests.
- Verification: command runs only workflow-live tests and does not affect default unit loop.

## Task 2: Add preflight checks and environment contract (45 min)
- Validate DB DSN and external service requirements before running suite.
- Enforce DSN separation from both `tenderbot` and `tenderbot_test`, and assert runtime DB identity.
- Verification: invalid env produces clear, single-point failure message.

## Task 3: Add shared setup/teardown helpers (60 min)
- Implement reusable fixtures for run-scoped data creation and cleanup.
- Verification: tests can create isolated records and cleanup consistently.

## Task 4: Add docs and usage guidance (25 min)
- Document commands, expected runtime, and when to run locally/CI.
- Verification: README includes clear instructions for this lane.

# Notes

This story only establishes the harness and execution lane. Job-specific live coverage is intentionally split into follow-up stories.
