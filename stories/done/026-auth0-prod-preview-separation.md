---
id: 026
title: Split Auth0 configuration for production vs preview/staging frontend flows
status: done
priority: high
labels: [auth, frontend, backend, staging, cloudflare]
estimate: medium
created: 2026-02-15
updated: 2026-02-15
---

# User Story

As a developer,
I want separate Auth0 app configuration for prod and preview/staging usage,
So that preview URL flexibility does not weaken production auth posture.

# Problem Statement

Cloudflare preview URLs are dynamic; Auth0 callback/logout/web-origin rules for preview flows can require wider patterns than production should allow. A single Auth0 app increases risk and operational friction.

Preview auth flow configuration is required for real QA, but automated gated validation can be deferred when live credentials are unavailable.

# Proposed Solution (High-Level)

Adopt environment split:
- Production frontend uses strict prod Auth0 SPA app/client
- Preview frontend builds use staging Auth0 SPA app/client with preview-compatible URL allowances
- Ensure audience/issuer alignment with backend envs
- Keep `main` production domain auth config locked to exact URLs
- Configure preview URLs to support `https://*.signup-01m.pages.dev` where allowed by Auth0 settings

# Acceptance Criteria

- [x] Auth0 prod and staging app/client strategy is documented and approved
- [x] Cloudflare Pages production env vars point to prod Auth0 client/domain/audience
- [x] Cloudflare Pages preview env vars point to staging Auth0 client/domain/audience
- [x] Backend staging auth envs align with staging audience/issuer values
- [x] Production app has exact callback/logout/web-origin coverage for `https://app.tenderbot.ai`
- [x] Preview app/client supports callback/logout/web-origin coverage for Cloudflare preview URLs (`*.signup-01m.pages.dev`)

# Technical Context

## Current State
- Frontend Auth0 values are build-time public env vars (`/signup/app/lib/auth0.ts`)
- Existing Auth0 runbook references Render-era domains (`/signup/docs/runbook/auth0.md`)
- Backend validates issuer/audience via env (`/backend/docs/auth/jwt-auth.md`)
- Existing Auth0 SPA app named `app.tenderbot.ai` currently contains Render-era URLs and must be updated
- Auth0 Management API credentials are available in Doppler (`AUTH0_MGMT_CLIENT_ID`, `AUTH0_MGMT_CLIENT_SECRET`, `TENDERBOT_AUTH0_DOMAIN`)

## Proposed Changes
- Auth0 tenant/app configuration updates should be done via Management API using M2M credentials
- Cloudflare Pages env matrix per environment
- Documentation updates for exact env mapping and allowed URLs

## File Locations
- `/signup/app/lib/auth0.ts`
- `/signup/docs/runbook/auth0.md`
- `/backend/docs/auth/jwt-auth.md`
- Cloudflare Pages project settings (manual)

## Auth0 Management Scopes
- `read:clients`
- `update:clients`
- `create:clients`
- `read:resource_servers`
- `update:resource_servers`

# Open Questions

- [x] Single Auth0 app across all envs? **No; use prod + staging separation.**
- [x] Preview URLs should use prod Auth0 client? **No.**
- [x] Is preview auth flow optional? **Configuration is mandatory; automated auth-gated validation may be deferred.**

# Dependencies

- Depends on Story #024 (Cloudflare Pages project)
- Depends on Story #025 (staging CORS preview support)

# Notes

If Auth0 wildcard support is constrained in tenant settings, fallback must still preserve authenticated preview QA by using a documented branch alias strategy with stable custom subdomains.
