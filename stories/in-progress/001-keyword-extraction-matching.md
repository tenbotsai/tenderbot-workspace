---
id: 001
title: Keyword Extraction for Better Tender Matching
status: in-progress
priority: high
labels: [matching, llm, ingestion, performance]
estimate: large
created: 2026-02-07
updated: 2026-02-12
---

# User Story

As a TenderBot user,
I want tender matches to be more accurate even when CPV codes are unreliable,
So that I do not miss relevant opportunities or get irrelevant matches.

# Problem Statement

Current deterministic candidate filtering depends on CPV overlap before LLM refinement. This causes missed matches when CPV data is noisy or incomplete.

Current behavior in scope:
- Candidate query uses `status`, `updated_at_source`, CPV overlap, and region filtering.
- LLM refinement only sees candidates returned from deterministic filtering.

If deterministic filtering excludes relevant tenders, LLM cannot recover them.

# Proposed Solution (High-Level)

Add extracted tender keywords and include them in deterministic filtering.

Target matching rule (confirmed):
- Keep existing guardrails (`status`, time window, region filtering)
- Update overlap clause to: `cpv overlap OR extracted keyword overlap`

Implementation is delivered in phases to reduce risk:
1. Add schema and indexes for extracted keywords + metadata.
2. Add asynchronous keyword extraction pipeline (OpenAI Batch API) with idempotent writes.
3. Add backfill for existing tenders missing extracted keywords.
4. Roll out prefilter update behind a feature flag with metrics and rollback path.

# Acceptance Criteria

- [ ] Tenders can store extracted keywords and extraction metadata (`model`, `version`, timestamps, error state).
- [ ] Keyword extraction pipeline exists and writes idempotently for new/updated tenders.
- [ ] Backfill can process existing tenders incrementally and skip already-processed rows.
- [ ] Deterministic candidate filter preserves existing status/time/region guards and uses `(cpv overlap OR extracted keyword overlap)`.
- [ ] Missing/failed keyword extraction does not break matching flow (CPV path still works).
- [ ] Query performance is validated with index-backed plan checks (`EXPLAIN ANALYZE`) and no material regression.
- [ ] Feature flag allows immediate rollback to CPV-only overlap logic.
- [ ] Instrumentation captures extraction success/failure and candidate-count distribution before/after rollout.

# Technical Context

## Current State

- Candidate filtering query lives in `/backend/tenderbot/data/tenders/sql.py` (`FIND_MATCHING_CANDIDATES`).
- Tender repository path is `/backend/tenderbot/data/tenders/repo.py`.
- Matching orchestration path is `/backend/tenderbot/tasks/flows/matching_flow.py`.
- LLM refinement service path is `/backend/tenderbot/core/tender_match/service.py`.
- Ingestion flow path is `/backend/tenderbot/tasks/flows/ingest_tenders.py`.

## Proposed Changes

- Add tender extraction fields and index via migration under `/backend/tenderbot/data/migrations/versions/`.
- Extend tender entity and repository SQL mapping for extraction fields.
- Add OpenAI Batch extraction service module under `/backend/tenderbot/services/`.
- Add extraction flow/task under `/backend/tenderbot/tasks/flows/`.
- Add feature flag setting in `/backend/tenderbot/config/settings.py` to switch between CPV-only and CPV-or-keywords overlap.
- Update deterministic filter SQL to include extracted keyword overlap branch.

## File Locations

- `/backend/tenderbot/data/tenders/sql.py`
- `/backend/tenderbot/data/tenders/repo.py`
- `/backend/tenderbot/core/tenders/entity.py`
- `/backend/tenderbot/tasks/flows/matching_flow.py`
- `/backend/tenderbot/tasks/flows/ingest_tenders.py`
- `/backend/tenderbot/config/settings.py`
- `/backend/tenderbot/data/migrations/versions/`
- `/backend/tests/unit/tenderbot/data/`
- `/backend/tests/unit/tenderbot/tasks/flows/`

# Open Questions

- [x] Prefilter overlap logic: `cpv AND keywords` or `cpv OR keywords`? **Use `cpv OR extracted keywords`.**
- [x] Region behavior with new overlap logic? **Keep current region guard unchanged.**
- [x] Sync extraction during ingestion vs async pipeline? **Async extraction pipeline to avoid ingestion latency spikes.**
- [x] Rollout safety? **Use feature flag with CPV-only fallback.**

# Dependencies

None

# Implementation Tasks

## Task 1: Add schema and indexes for extracted keywords (45 min)
- Add migration to `tenders` for `extracted_keywords` and extraction metadata fields.
- Add GIN index on `extracted_keywords`.
- Verification: migration applies cleanly and rollback works.

## Task 2: Extend tender entity/repository mappings (45 min)
- Update domain entity and DB mapping for new fields.
- Update tender upsert/read SQL and mapping tests.
- Verification: repository tests pass and fields round-trip.

## Task 3: Build keyword extraction pipeline (90 min)
- Add OpenAI Batch API integration service with retries and idempotent write semantics.
- Add extraction flow/task to process pending tenders in chunks.
- Verification: unit tests cover success, partial failure, and retry-safe duplicate execution.

## Task 4: Implement incremental backfill (60 min)
- Add selection logic for tenders missing keywords or stale version.
- Add chunking, checkpointing, and dry-run support.
- Verification: backfill can resume without reprocessing completed rows.

## Task 5: Add feature-flagged prefilter update (60 min)
- Update deterministic matching SQL to include extracted keyword overlap when enabled.
- Keep existing status/time/region guards.
- Verification: query tests cover CPV-only hit, keyword-only hit, neither hit, and region mismatch.

## Task 6: Add observability and rollout guardrails (45 min)
- Add counters/logging for extraction outcomes and candidate counts.
- Add rollout notes with rollback instructions.
- Verification: metrics/log events emitted in tests and documented in story notes.

## Task 7: Validate end-to-end and quality gates (45 min)
- Run backend checks per repo policy (`mise run test`, `mise run test-coverage`, `mise run lint`, `mise run typecheck`).
- Capture baseline vs post-change candidate-count metrics on sample data.
- Verification: checks pass and no material query performance regression is observed.

# Notes

- This story is intentionally scoped to deterministic filtering + extraction pipeline + safe rollout.
- User-facing scoring controls remain out of scope (covered by Story #002).
- If implementation risk becomes too high, split execution into follow-up tickets:
  1) schema + feature-flagged query changes, 2) extraction pipeline, 3) backfill rollout.
