---
id: 004
title: Set Up Staging Environment
status: unrefined
priority: high
labels: [infrastructure, deployment, testing]
estimate: unknown
created: 2026-02-07
updated: 2026-02-07
---

# User Story

As a developer,
I want a staging environment that mirrors production,
So that I can test changes end-to-end before deploying to production.

# Problem Statement

We currently have no staging environment. This means:

- Can't run E2E tests without affecting production
- Can't test deployment process before production
- Can't demo new features in production-like environment
- Can't test integrations (Stripe, Auth0, email) safely
- Risk of breaking production with untested changes

# Proposed Solution (High-Level)

Create a staging environment with:

- Separate backend API deployment
- Separate frontend deployment
- Separate database (staging data)
- Separate Prefect instance
- Test mode integrations:
  - Stripe test mode
  - Auth0 test tenant or separate application
  - Email provider test/sandbox mode

**Requirements:**
- Infrastructure as code (reproducible)
- Automated deployment pipeline
- Separate environment variables
- Data seeding for testing
- Cost-effective (can use smaller instances)

# Acceptance Criteria

- [ ] Staging backend deployed and accessible
- [ ] Staging frontend deployed and accessible
- [ ] Staging database created with test data
- [ ] Prefect workflows running in staging
- [ ] Stripe test mode configured
- [ ] Auth0 test environment configured
- [ ] Email sending in test/sandbox mode
- [ ] Deployment pipeline for staging
- [ ] Documentation for using staging

# Technical Context

## Current State
- Production only
- Render for backend deployment (based on PR #59)
- Unknown frontend hosting
- Single database instance

## Proposed Infrastructure
- Backend: Render staging environment
- Frontend: [TBD - current hosting?]
- Database: Separate PostgreSQL instance
- Prefect: Separate workspace or test mode

## File Locations
- Render blueprint: `/backend/render.yaml`
- Environment config: `/backend/.env.example`
- Deployment docs: [TBD]

# Open Questions

- [ ] Where is frontend currently hosted?
- [ ] Should staging use same Render account or separate?
- [ ] How to manage environment variables securely?
- [ ] What's the database setup? (Render PostgreSQL, external RDS, etc.)
- [ ] Do we need separate Prefect Cloud workspace?
- [ ] Should staging auto-deploy from a specific branch (e.g., `develop`)?
- [ ] How to seed staging database with test data?
- [ ] What's the cost of running staging 24/7 vs on-demand?

# Dependencies

None (but blocks Story #003 E2E testing)

# Notes

This is critical infrastructure work. Should be prioritized to unblock comprehensive testing.
