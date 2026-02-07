# TenderBot Product Roadmap

This roadmap tracks TenderBot's development status and upcoming work.

**Completed work** is documented in feature specs (`/features/`)
**Current and future work** is tracked in stories (`/stories/`)

Last updated: 2026-02-07

---

## 🎯 Current Status Overview

**MVP Core Features** - ✅ **COMPLETE** (January 2026)
- All essential functionality for first paying customers is live
- Backend: Find a Tender ingestion, AI matching, email delivery, Prefect workflows
- Frontend: Conversational onboarding, dashboard with 5 tabs, Auth0 + Stripe integration
- See Phase 1 section below for full feature list

**Current Focus** - 🚧 **Q1 2026**
- Fix matching quality issues (CPV code reliability)
- Add comprehensive testing (onboarding, dashboard, E2E)
- Set up staging environment
- Integrate email provider for live alerts
- See story list below for details

---

## ✅ Phase 1: MVP Core Features (COMPLETE)

### 1.1 Data Ingestion & Processing
- [x] [Find a Tender API Integration](./features/data-ingestion.md) - ✅ COMPLETE
- [x] [Tender Data Normalization](./features/data-ingestion.md#normalization) - ✅ COMPLETE
- [ ] [Contracts Finder API Integration](./features/data-ingestion.md#contracts-finder) - 🟡 PLANNED

### 1.2 AI-Powered Matching
- [x] [CPV Category Matching](./features/matching-engine.md) - ✅ COMPLETE
- [x] [Keyword-Based Filtering](./features/matching-engine.md#keywords) - ✅ COMPLETE
- [x] [LLM Refinement & Summarization](./features/matching-engine.md#llm-refinement) - ✅ COMPLETE
- [x] [Confidence Scoring](./features/matching-engine.md#confidence) - ✅ COMPLETE

### 1.3 Alert System
- [x] [Email Alert Delivery](./features/alert-delivery.md) - ✅ COMPLETE
- [x] [Alert Scheduling (Hourly/Daily/Weekly)](./features/alert-delivery.md#scheduling) - ✅ COMPLETE
- [x] [Email Templates & Rendering](./features/alert-delivery.md#templates) - ✅ COMPLETE
- [x] [Delivery Tracking & History](./features/alert-delivery.md#tracking) - ✅ COMPLETE

### 1.4 User Onboarding
- [x] [Conversational Onboarding Flow](./features/onboarding.md) - ✅ COMPLETE
- [x] [AI-Powered Category Suggestions](./features/onboarding.md#suggestions) - ✅ COMPLETE
- [x] [Tender Preview During Signup](./features/onboarding.md#preview) - ✅ COMPLETE
- [x] [Auth0 OAuth Integration](./features/authentication.md) - ✅ COMPLETE

### 1.5 Dashboard
- [x] [Tender Matches Feed](./features/dashboard.md) - ✅ COMPLETE
- [x] [Alert Profile Management](./features/dashboard.md#alerts) - ✅ COMPLETE
- [x] [Saved Tenders](./features/dashboard.md#saved) - ✅ COMPLETE
- [x] [Email Delivery History](./features/dashboard.md#history) - ✅ COMPLETE
- [x] [User Actions (Interested/Dismiss)](./features/dashboard.md#actions) - ✅ COMPLETE

### 1.6 Billing & Subscriptions
- [x] [Stripe Checkout Integration](./features/billing.md) - ✅ COMPLETE
- [x] [Subscription Plans (Basic/Pro)](./features/billing.md#plans) - ✅ COMPLETE
- [x] [Webhook Handling](./features/billing.md#webhooks) - ✅ COMPLETE
- [ ] [Stripe Customer Portal](./features/billing.md#portal) - 🟡 IN PROGRESS

---

## 🎯 Current Work (Stories)

**We use a story-based system for tracking work.** See `/stories/` directory for all stories.

Stories move through: `unrefined` → `refined` → `in-progress` → `done`

### High Priority Stories (Unrefined)

**[#001: Keyword Extraction for Better Matching](./stories/unrefined/001-keyword-extraction-matching.md)**
- Extract keywords from tenders using LLM batch API
- Addresses CPV code reliability issues (mis-categorization, broad categories)
- Requires careful design - large feature

**[#003: Comprehensive Testing Strategy](./stories/unrefined/003-comprehensive-testing-strategy.md)**
- Full test coverage for onboarding and dashboard
- Mock LLM responses and Auth0 for automated testing
- Needs staging environment (#004)

**[#004: Staging Environment](./stories/unrefined/004-staging-environment.md)**
- Set up staging for E2E testing
- Separate deployments for backend/frontend/database
- Unblocks comprehensive testing

**[#005: Email Provider Integration](./stories/unrefined/005-email-provider-integration.md)**
- Integrate email provider API (Resend/SendGrid/AWS SES)
- Emails not currently going out - blocking user value
- DNS setup (SPF, DKIM), bounce handling

### Medium Priority Stories (Unrefined)

**[#002: Relevance Scoring Improvements](./stories/unrefined/002-relevance-scoring-improvements.md)**
- Define explicit LLM scoring rubric
- Consider user preference controls (geography vs content weight)
- Improve match quality transparency

**[#006: Automated Email Testing](./stories/unrefined/006-automated-email-testing.md)**
- Visual regression tests for email rendering
- Test across email clients
- Enhance CLI preview tool

**[#007: Improve Match Descriptions](./stories/unrefined/007-improve-match-descriptions.md)**
- Generate specific relevance explanations
- Highlight matched keywords/categories
- Replace generic "matches your category" text

**[#009: Preserve Onboarding Chat History](./stories/unrefined/009-preserve-onboarding-chat-history.md)**
- Fix bug: chat history wiped after auth redirect
- Extend sessionStorage to include message history
- Maintain conversation continuity

### Low Priority Stories (Unrefined)

**[#008: Fix Logo Rendering](./stories/unrefined/008-fix-logo-rendering.md)**
- Visual bug: logo doesn't match prototype
- Quick fix once investigated

---

## 📝 Story Management

All active work is tracked in `/stories/`. See [stories/README.md](./stories/README.md) for:
- How to work with stories
- Refinement process
- Status definitions
- Prioritization criteria

**For coding agents:** Stories in `/stories/refined/` are ready for implementation with full context.

---

## 📊 Status Key

- ✅ **COMPLETE** - Feature is live in production
- 🟡 **IN PROGRESS** - Currently being developed
- 🔜 **NEXT UP** - Prioritized for immediate development
- 📋 **PLANNED** - In roadmap but not yet scheduled
- ⏸️ **ON HOLD** - Deprioritized temporarily
- ❌ **CANCELLED** - Feature removed from roadmap

---

## 📝 Notes

### Feature Specification Documents

Each feature links to a detailed specification document in the `./features/` directory containing:
- **Overview** - What the feature does and why it's valuable
- **User Stories** - Who benefits and how they'll use it
- **Technical Design** - Architecture, data models, API changes
- **Implementation Plan** - Step-by-step development approach
- **Success Metrics** - How we'll measure success
- **Dependencies** - What needs to be built first

### Prioritization Criteria

Features are prioritized based on:
1. **Customer demand** - Direct feedback from users
2. **Business impact** - Revenue potential and retention
3. **Strategic value** - Market differentiation
4. **Technical feasibility** - Development effort and risk
5. **Dependencies** - Required foundational features

### Contributing to the Roadmap

To propose a new feature or change priorities:
1. Create a feature specification in `./features/`
2. Add to this roadmap with appropriate status
3. Open a discussion in the team channel
