---
id: 025
title: Add staging-only relaxed CORS policy for Cloudflare preview frontends
status: done
priority: high
labels: [backend, security, cors, staging, cloudflare]
estimate: medium
created: 2026-02-15
updated: 2026-02-15
---

# User Story

As a developer,
I want staging API CORS to allow Cloudflare preview origins while prod remains strict,
So that preview frontends can test authenticated API flows without weakening production security.

# Problem Statement

Backend currently uses explicit origin allow-list only. Cloudflare preview URLs are dynamic (`*.pages.dev`), making staging preview support difficult without either constant env churn or broader policy controls.

# Proposed Solution (High-Level)

Implement optional CORS origin regex support in backend settings and app factory:
- Keep existing `TENDERBOT_CORS_ORIGINS` list support
- Add `TENDERBOT_CORS_ORIGIN_REGEX` for staging-only wildcard support
- Configure Dokploy staging env to allow preview domain pattern: `^https://([a-z0-9-]+\\.)?signup-01m\\.pages\\.dev$`
- Keep production config strict with explicit origins only (no regex)

# Acceptance Criteria

- [x] Backend settings include optional `cors_origin_regex` env-backed field
- [x] FastAPI CORS middleware consumes both exact origins and optional regex
- [x] Unit tests cover strict-list behavior and regex behavior
- [x] Dokploy staging compose env includes regex value for preview domains
- [x] Dokploy prod compose/env does not enable regex and remains strict
- [x] At least one browser request from a live preview origin to `api-staging.tenderbot.ai` succeeds (CORS preflight + request); auth-gated request validation can be deferred

# Technical Context

## Current State
- CORS middleware uses only parsed comma-separated origins (`/backend/tenderbot/api/app.py`)
- Settings has `cors_origins` but no regex field (`/backend/tenderbot/config/settings.py`)
- Staging/prod compose files pass through `TENDERBOT_CORS_ORIGINS`
- Preview auth testing is a hard requirement; UI-only preview support is not sufficient

## Proposed Changes
- Add `cors_origin_regex` to settings
- Pass `allow_origin_regex` to `CORSMiddleware` when configured
- Add/extend tests under backend unit test suite
- Update Dokploy env docs/config references
- Configure staging Dokploy env with `TENDERBOT_CORS_ORIGIN_REGEX=^https://([a-z0-9-]+\\.)?signup-01m\\.pages\\.dev$`

## File Locations
- `/backend/tenderbot/config/settings.py`
- `/backend/tenderbot/api/app.py`
- `/backend/tests/unit/tenderbot/api/test_app.py`
- `/backend/dokploy/staging.compose.yml`
- `/backend/dokploy/prod.compose.yml`

# Open Questions

- [x] Should prod allow wildcard preview origins? **No.**
- [x] Should staging use wildcard for previews? **Yes, via regex only in staging.**
- [x] Must preview auth/API flows work end-to-end? **Yes, mandatory.**

# Dependencies

- Enables Story #026 and #028
- Related to Story #018 smoke coverage goals

# Notes

Do not modify unrelated auth/token validation logic. Scope is CORS transport policy only.
