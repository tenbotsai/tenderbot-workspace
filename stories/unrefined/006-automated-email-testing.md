---
id: 006
title: Automated Email Rendering Tests
status: unrefined
priority: medium
labels: [testing, email, alerts]
estimate: unknown
created: 2026-02-07
updated: 2026-02-07
---

# User Story

As a developer,
I want automated tests for email rendering,
So that I can ensure emails look correct across different email clients without manual testing.

# Problem Statement

Need to test that alert emails render correctly:

- HTML structure is valid
- Styles render properly (inline CSS, email client compatibility)
- Content displays correctly (tender cards, links, footer)
- Mobile responsive layout works
- Images load properly (logo, etc.)
- Links are clickable
- No broken templates

Currently, the only way to verify emails is to:
1. Trigger a real alert
2. Check inbox manually
3. Open in multiple email clients

This is slow, unreliable, and doesn't scale.

# Proposed Solution (High-Level)

**Automated Testing Approaches:**

1. **Template Rendering Tests**
   - Unit tests that render templates with fixture data
   - Assert on HTML structure and content
   - Fast, run on every commit

2. **Visual Regression Tests**
   - Render email HTML in headless browser
   - Take screenshot
   - Compare to baseline
   - Tools: Playwright, Percy, BackstopJS

3. **Email Client Preview**
   - Use service like Litmus or Email on Acid
   - Send test emails to multiple clients
   - Automated screenshot capture
   - (More expensive, slower)

4. **CLI Preview Tool**
   - Dev command to generate and preview email locally
   - Open in browser for quick visual check
   - Useful for development iteration

# Acceptance Criteria

- [ ] Unit tests for email template rendering
- [ ] Visual regression tests for email layout
- [ ] CLI command to preview emails locally
- [ ] Tests run in CI pipeline
- [ ] Documentation for testing email changes

# Technical Context

## Current State
- Email renderer: `/backend/tenderbot/services/email_renderer.py`
- CLI preview command exists: `POST /cli/email-preview` (PR #57)
- No automated visual tests

## Proposed Changes
- Add unit tests for renderer
- Set up visual regression testing
- Enhance CLI preview tool
- Add email fixtures for testing

## File Locations
- Email renderer: `/backend/tenderbot/services/email_renderer.py`
- Email templates: (inline in renderer)
- CLI preview: `/backend/tenderbot/api/routers/cli_router.py`
- Tests: `/backend/tests/services/test_email_renderer.py`

# Open Questions

- [ ] Which visual regression tool to use?
- [ ] Do we need to test across multiple email clients? (Gmail, Outlook, Apple Mail)
- [ ] Should we extract templates to separate files vs inline?
- [ ] Is the CLI preview command sufficient for development?
- [ ] Do we need email-specific CI checks?

# Dependencies

- Story #005 (Email provider integration) - optional, can mock

# Notes

**Suggested Approach:**
1. Start with unit tests (quick win)
2. Add CLI preview tool enhancement
3. Add visual regression if needed
4. Consider Litmus/Email on Acid for final validation only
