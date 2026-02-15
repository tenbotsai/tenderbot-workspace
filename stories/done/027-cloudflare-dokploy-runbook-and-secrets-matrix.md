---
id: 027
title: Create deployment runbook and secrets matrix for Cloudflare Pages + Dokploy
status: done
priority: medium
labels: [documentation, ops, secrets, cloudflare, dokploy]
estimate: small
created: 2026-02-15
updated: 2026-02-15
---

# User Story

As an operator,
I want a single runbook and env-var matrix for frontend/backend deployment integration,
So that setup and incident response are repeatable and low-risk.

# Problem Statement

Current docs still reference Render and do not fully document Cloudflare Pages + Hetzner/Dokploy + Doppler integration, including preview-mode caveats.

# Proposed Solution (High-Level)

Produce docs covering:
- Cloudflare Pages setup steps
- Environment variable matrix (prod vs preview vs local)
- Auth0 and CORS configuration map
- Verification checklist and rollback path
- Explicit reference to `CLAUDE.md` safety rules from workspace agent notes
- Doppler key ownership and usage map

# Acceptance Criteria

- [x] Frontend README deployment section is Cloudflare-first
- [x] Auth0 runbook is updated for Cloudflare domains and preview strategy
- [x] New/updated runbook includes env-var matrix across Cloudflare, Dokploy, Auth0, Doppler
- [x] Workspace `AGENTS.md` includes a reference to `/CLAUDE.md` for infra guardrails
- [x] Migration checklist includes pre-cutover and post-cutover validation steps
- [x] Runbook includes concrete identifiers and ownership boundaries:
  - Cloudflare account ID: `b42587fbee69b4ffcca07f9ea4629d0b`
  - Cloudflare zone ID (`tenderbot.ai`): `989accb63dc7218760076825bcfdd01b`
  - Pages project name: `signup`
  - Production app domain: `app.tenderbot.ai`

# Technical Context

## Current State
- Render references exist in frontend docs
- Infra safety guidance exists in `/CLAUDE.md` but not referenced in workspace agent notes
- Hetzner/Dokploy infra state captured in `/INFRA_STATE.md`
- Core credentials now exist in Doppler for Cloudflare and Auth0 management APIs

## Proposed Changes
- Documentation updates only
- No application logic change
- Add an explicit secrets matrix section that maps each key to owner/system of use

## File Locations
- `/signup/README.md`
- `/signup/docs/runbook/auth0.md`
- `/AGENTS.md`
- Optional new doc: `/signup/docs/runbook/cloudflare-pages.md`

## Required Doppler Key Map
- `CF_PAGES_API_KEY`: Cloudflare API token for Pages + DNS automation
- `CF_API_KEY`: legacy/limited Cloudflare token (document as legacy if retained)
- `DOKPLOY_API_KEY`: Dokploy API access for backend env/deploy operations
- `TENDERBOT_AUTH0_DOMAIN`: Auth0 tenant domain
- `AUTH0_MGMT_CLIENT_ID`: Auth0 Management API M2M client id
- `AUTH0_MGMT_CLIENT_SECRET`: Auth0 Management API M2M client secret
- `TENDERBOT_AUTH0_AUDIENCE`: API audience used by frontend token requests/backend validation
- `TENDERBOT_AUTH0_ISSUER`: expected JWT issuer for backend validation
- `TENDERBOT_AUTH0_ALGORITHMS`: expected JWT algorithms (RS256)
- `TENDERBOT_CORS_ORIGINS`: exact origin allow-list
- `TENDERBOT_CORS_ORIGIN_REGEX` (new): staging-only regex for preview origins
- `TENDERBOT_APP_BASE_URL`: backend app base URL used in redirects/links

## Cloudflare Pages Environment Variables (managed in Pages)
- `NEXT_PUBLIC_APP_URL`
- `NEXT_PUBLIC_API_BASE_URL`
- `NEXT_PUBLIC_AUTH0_DOMAIN`
- `NEXT_PUBLIC_AUTH0_CLIENT_ID`
- `NEXT_PUBLIC_AUTH0_AUDIENCE`
- `NEXT_PUBLIC_AUTH0_REDIRECT_URI`
- `NEXT_PUBLIC_AUTH0_USE_LOCAL_STORAGE`

# Open Questions

- [x] Should this story include code changes? **No, docs/runbook only.**

# Dependencies

- Best delivered after Stories #024-#026 decisions are finalized

# Notes

Keep this runbook operationally explicit: include exact knobs and where each setting is managed.
