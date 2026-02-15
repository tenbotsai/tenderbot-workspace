---
id: 028
title: Add smoke checks for Cloudflare preview to staging API integration
status: done
priority: medium
labels: [testing, e2e, staging, frontend, backend]
estimate: medium
created: 2026-02-15
updated: 2026-02-15
---

# User Story

As a developer,
I want lightweight smoke checks against preview frontend and staging API,
So that we catch integration regressions in auth and core API plumbing before production promotion.

# Problem Statement

Unit and contract tests are strong locally, but deployment-specific failures (CORS, callback URLs, env mismatches) happen only in hosted environments.

# Proposed Solution (High-Level)

Define and run a minimal smoke suite for hosted environments:
- Unauthenticated route availability
- Protected route redirect/login loop safety
- Auth callback completion
- Optional authenticated API call success path from frontend when a valid smoke token is provided
- Optional API-only health/auth checks for fast triage
- Preview auth flow configuration remains important, but auth-gated smoke validation can be skipped when credentials are not available

# Acceptance Criteria

- [x] Smoke test scope is documented with clear pass/fail criteria
- [x] At least one runnable smoke command/checklist exists for preview deployment validation
- [x] Failure triage guide maps common failures to likely config causes (CORS/Auth0/env)
- [x] Smoke checks are run at least once successfully against a live preview and staging API
- [x] Ownership and execution cadence are defined
- [x] Smoke checks include hosted checks for `/login`, `/auth/callback`, and staging API health; authenticated API assertion is optional when a smoke token is unavailable

# Technical Context

## Current State
- Existing Playwright tests are local/static oriented (`/signup/tests/e2e.spec.ts`)
- Existing unrefined staging smoke story exists (`/stories/unrefined/018-staging-e2e-contract-smoke-suite.md`)
- Preview environment is `*.signup-01m.pages.dev`; production app domain is `app.tenderbot.ai`

## Proposed Changes
- Extend or add hosted-environment smoke checks (script/process)
- Avoid brittle full-journey E2E initially; prioritize high-signal checks

## File Locations
- `/signup/tests/e2e.spec.ts` (or new hosted smoke spec)
- `/signup/docs/runbook/` (smoke execution guide)
- `/stories/unrefined/018-staging-e2e-contract-smoke-suite.md` (link/supersede note)

# Open Questions

- [x] Full end-to-end checkout in day one smoke? **No; keep initial suite lightweight and reliable.**
- [x] Run on every PR? **Start manual/triggered; automate after stability baseline.**

# Dependencies

- Depends on Stories #024, #025, #026
- Refines and effectively supersedes Story #018

# Notes

Focus on fast, deterministic checks that identify environment integration drift quickly.
