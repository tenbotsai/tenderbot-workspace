---
id: 024
title: Migrate frontend hosting from Render to Cloudflare Pages (prod + previews)
status: done
priority: high
labels: [frontend, deployment, cloudflare, infrastructure]
estimate: medium
created: 2026-02-15
updated: 2026-02-15
---

# User Story

As a developer,
I want the `signup` frontend hosted on Cloudflare Pages with GitHub integration,
So that production deploys are stable and previews are automatic on the free tier.

# Problem Statement

Frontend hosting is still Render-oriented in docs/config, while the backend has moved to Hetzner + Dokploy. We need a low-cost, static-friendly deployment target with branch previews and a clean migration path.

# Proposed Solution (High-Level)

Set up one Cloudflare Pages project for `signup`:
- Production: `main` branch -> `app.tenderbot.ai`
- Preview deployments: all non-prod branches on `*.pages.dev`
- No Workers/Pages Functions required
- Keep static export build (`next build` with `output: export`)

# Acceptance Criteria

- [x] Cloudflare Pages project is connected to the GitHub repo and builds from `signup/`
- [x] Build config is documented and validated (`npm ci && npm run build`, output `out/`, Node 20)
- [x] Production custom domain `app.tenderbot.ai` points to Pages and serves the latest `main`
- [x] Preview deployments are enabled for PR/branch workflows
- [x] Preview deployment setting remains enabled for all non-production branches (`preview_deployment_setting=all`)
- [x] Render-specific frontend deployment references are removed/updated in docs

# Technical Context

## Current State
- Frontend is static export-ready (`/signup/next.config.mjs`)
- Render deployment instructions still exist (`/signup/README.md`)
- Backend API base URL is configured via `NEXT_PUBLIC_API_BASE_URL` (`/signup/app/lib/api.ts`)
- Cloudflare Pages project already exists and deploys successfully:
  - project: `signup`
  - pages.dev domain: `signup-01m.pages.dev`
  - build command: `npm ci && npm run build`
  - output directory: `out`
  - production branch: `main`

## Proposed Changes
- Cloudflare Pages and DNS setup should be managed via Cloudflare API where possible
- Documentation updates for deployment platform and branch behavior
- No frontend runtime architecture changes required

## File Locations
- `/signup/next.config.mjs`
- `/signup/README.md`
- `/signup/docs/runbook/` (new cloudflare runbook section or file)

## Cloudflare Identifiers
- Account ID: `b42587fbee69b4ffcca07f9ea4629d0b`
- Zone ID (`tenderbot.ai`): `989accb63dc7218760076825bcfdd01b`
- Pages project: `signup`

# Open Questions

- [x] Separate frontend staging domain required? **No; use preview deployments + staging API.**
- [x] Workers required? **No; static Pages deployment only.**
- [x] Production app domain? **`app.tenderbot.ai`.**

# Dependencies

- Depends on Story #025 and #026 for preview auth/API behavior
- Supersedes frontend-hosting portions of Story #004

# Notes

Keep this story focused on hosting migration and deploy pipeline wiring. Auth/CORS policy work is tracked separately.
