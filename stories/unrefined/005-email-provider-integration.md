---
id: 005
title: Integrate Email Provider API
status: unrefined
priority: high
labels: [email, integration, alerts]
estimate: unknown
created: 2026-02-07
updated: 2026-02-07
---

# User Story

As a TenderBot user,
I want to receive email alerts when new tender matches are found,
So that I can respond to opportunities quickly.

# Problem Statement

Email provider API is not yet integrated, so alerts are not being sent to users.

**Current State:**
- Email sending code exists in backend
- Email templates and rendering implemented
- Delivery tracking in place
- BUT: No actual email provider configured

**Needs:**
- Choose email provider (Resend, SendGrid, AWS SES, Postmark)
- Configure API credentials
- Set up DNS records (SPF, DKIM)
- Test email deliverability
- Handle bounces and failures

# Proposed Solution (High-Level)

1. **Select Email Provider** - Evaluate options based on:
   - Cost
   - Deliverability
   - API simplicity
   - Webhook support (for bounces, opens, clicks)

2. **Integration Steps:**
   - Sign up for provider account
   - Configure API key in environment
   - Set up sender domain (alerts@tenderbot.com)
   - Configure DNS records
   - Update email client implementation if needed
   - Test with real sends

3. **Monitoring:**
   - Set up webhook for bounce handling
   - Track delivery rates
   - Monitor spam complaints

# Acceptance Criteria

- [ ] Email provider selected and account created
- [ ] API credentials configured in production
- [ ] DNS records set up (SPF, DKIM, DMARC)
- [ ] Test emails send successfully
- [ ] Alert emails deliver to users
- [ ] Bounce handling implemented
- [ ] Delivery metrics tracked
- [ ] Staging environment uses test/sandbox mode

# Technical Context

## Current State
- Email client: `/backend/tenderbot/services/email_client.py`
- Generic implementation with configurable base URL
- Email templates: `/backend/tenderbot/services/email_renderer.py`
- Delivery tracking: `/backend/tenderbot/data/delivery_history_repo.py`

## Proposed Changes
- Minimal - email client already designed for external provider
- May need provider-specific error handling
- Add webhook endpoint for bounce notifications

## File Locations
- Email client: `/backend/tenderbot/services/email_client.py`
- Email task: `/backend/tenderbot/tasks/email_sending_task.py`
- Config: Environment variables

# Open Questions

- [ ] Which email provider should we use?
- [ ] What's our expected email volume? (affects pricing)
- [ ] Do we own tenderbot.com domain?
- [ ] Who has access to DNS management?
- [ ] Do we need transactional + marketing emails or just transactional?
- [ ] Should we implement unsubscribe handling first?

# Dependencies

None (but may want Story #004 staging environment for testing)

# Notes

This is blocking real user value. Should be high priority once provider is selected.

**Provider Comparison Needed:**
- Resend: Developer-friendly, good pricing
- SendGrid: Enterprise, higher volume
- AWS SES: Cheapest, requires warm-up
- Postmark: Best deliverability, higher cost
