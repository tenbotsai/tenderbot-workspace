---
id: 003
title: Testing Strategy Epic for Onboarding and Dashboard
status: done
priority: high
labels: [testing, frontend, vitest, planning]
estimate: medium
created: 2026-02-07
updated: 2026-02-12
---

# User Story

As a developer,
I want onboarding and dashboard testing work split into implementable stories,
So that we can improve confidence quickly without mixing unrelated testing concerns.

# Problem Statement

Testing scope was previously grouped into one large story that combined frontend Vitest work, backend API tests, and staging E2E. That prevented parallel progress and created unclear ownership.

This refined epic is a parent tracker for FE Vitest-only delivery. Backend and staging E2E remain follow-on scope.

# Proposed Solution (High-Level)

Run testing delivery in phases with explicit boundaries.

**Phase 1 (in scope now): FE Vitest**
1. Story #010 - FE testing foundation with shared mocks/fixtures
2. Story #011 - Onboarding steps 1-5 coverage
3. Story #012 - Onboarding steps 6-7 and billing redirect coverage
4. Story #013 - Dashboard tab flow coverage

**Phase 2 (out of scope in this epic implementation pass):**
- Story #014 - Backend onboarding API contract tests
- Story #015 - Backend billing checkout/confirmation contract tests
- Story #016 - Backend dashboard API contract tests
- Story #017 - Backend fixture and integration harness hardening
- Story #018 - Staging E2E contract smoke suite (depends on Story #004)

# Acceptance Criteria

- [x] Stories #010, #011, #012, and #013 were delivered through the lifecycle and are now completed in `stories/done/`
- [x] Each child story contains resolved technical decisions and implementation tasks (<1 hour each)
- [x] FE testing scope is explicitly Vitest-only (no Playwright work)
- [x] Backend API testing and staging E2E are documented as follow-on scope
- [x] Implementation order and dependencies across child stories are explicit

# Technical Context

## Current State
- FE Vitest is configured in `/signup/vitest.config.ts` and `/signup/vitest.setup.ts`
- Existing FE tests focus mostly on step/core units (`/signup/tests/unit/onboarding/steps.test.ts`, `/signup/tests/unit/onboarding/flowCore.test.ts`)
- Dashboard tests are present but shallow (`/signup/tests/unit/dashboard/page.test.tsx`)
- No implementation-ready breakdown for onboarding page orchestration and dashboard tab effects

## Proposed Changes
- Use this epic as planning/coordination only
- Execute implementation through Stories #010-#013
- Keep FE test implementation under `/signup/tests/unit/`

## File Locations
- Parent epic: `/stories/refined/003-comprehensive-testing-strategy.md`
- Child stories: `/stories/refined/010-fe-testing-foundation-vitest.md` to `/stories/refined/013-fe-dashboard-tabs-vitest.md`

# Open Questions

- [x] Should FE scope include Playwright in this phase? **No. Vitest only.**
- [x] Should we enforce numeric coverage target per story? **No. Use critical-path assertions per story.**
- [x] What should follow FE phase first? **Backend API tests first, then staging E2E.**

# Dependencies

- Story #010
- Story #011
- Story #012
- Story #013
- Story #014
- Story #015
- Story #016
- Story #017
- Story #018
- Story #004 (staging environment prerequisite for Story #018)

# Implementation Tasks

## Task 1: Finalize FE scope guardrails (15 min)
- Confirm Story #010-#013 all state Vitest-only scope and explicit out-of-scope items.
- Verification: checklist review across child story files.

## Task 2: Sequence child story rollout (20 min)
- Enforce implementation order: #010 -> #011 -> #012 -> #013.
- Verification: dependencies in each story match rollout order.

## Task 3: Track FE completion against child ACs (30 min)
- Mark this epic complete only when all child acceptance criteria are met.
- Verification: child stories moved to done/in-progress lifecycle as applicable.

# Notes

This story is intentionally a planning parent epic, not a coding task. Coding agents should implement from Stories #010-#013.
