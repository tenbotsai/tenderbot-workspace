---
id: 001
title: Keyword Extraction for Better Tender Matching
status: unrefined
priority: high
labels: [matching, llm, ingestion, performance]
estimate: unknown
created: 2026-02-07
updated: 2026-02-07
---

# User Story

As a TenderBot user,
I want tender matches to be more accurate even when CPV codes are unreliable,
So that I don't miss relevant opportunities or get irrelevant matches.

# Problem Statement

Current matching relies heavily on CPV codes in the pre-filter stage (SQL query before LLM). This has three major issues:

1. **Inaccurate CPV codes in source data** - Public tenders are often mis-categorised due to human error
2. **Inaccurate CPV codes from users** - Our onboarding flow may not correctly establish relevant CPV codes for user's business
3. **Broad CPV categories** - Some CPV codes are too general, leading to poor quality matches

These issues mean the pre-filter returns too many irrelevant candidates or misses relevant ones entirely.

# Proposed Solution (High-Level)

Extract keywords from tenders at ingestion time (or post-ingestion) using LLM. Use these keywords to narrow down results when generating matches.

**Key Requirements:**
- Bulk process using OpenAI Batch API (cost optimization)
- May require separate API client implementation
- Prompt engineering for high-quality keyword extraction
- Store extracted keywords in database for matching queries

# Acceptance Criteria

- [ ] Keywords extracted from tender title, description, and other relevant fields
- [ ] Keywords stored in database and indexed for fast querying
- [ ] Matching pre-filter uses keywords in addition to CPV codes
- [ ] Batch processing keeps costs reasonable
- [ ] Match quality improves measurably

# Technical Context

## Current State
- Pre-filter query: `/backend/tenderbot/data/matching_repo.py`
- Uses CPV code overlap + keyword substring search on title/description
- Keywords are user-provided, not extracted from tenders

## Proposed Changes
- Add `extracted_keywords` JSONB column to `tenders` table
- Create batch job for keyword extraction (Prefect workflow)
- Implement OpenAI Batch API client
- Update matching pre-filter to use `extracted_keywords`

## File Locations
- Matching logic: `/backend/tenderbot/data/matching_repo.py`
- Ingestion: `/backend/tenderbot/tasks/flows/ingest_tenders_flow.py`
- OpenAI client: `/backend/tenderbot/services/openai_client.py`

# Open Questions

- [ ] Extract keywords during ingestion or as separate batch job?
- [ ] What prompt template yields best keyword quality?
- [ ] How many keywords per tender (5, 10, 20)?
- [ ] How to handle keywords for existing tenders (backfill)?
- [ ] What's the performance impact on matching queries?
- [ ] How do we measure match quality improvement?

# Dependencies

None

# Notes

This is a large feature requiring careful consideration. Needs refinement to break down into implementable tasks.
