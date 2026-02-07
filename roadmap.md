# TenderBot Product Roadmap

This roadmap tracks implemented features and outlines upcoming work for TenderBot. Each feature links to a detailed specification document.

Last updated: 2026-02-07

---

## 🎯 Current Status Overview

**Phase 1: MVP Core Features** - ✅ **COMPLETE** (January 2026)
- All essential functionality for first paying customers is live
- Backend ingestion, matching, and email delivery operational
- Frontend onboarding and dashboard fully functional
- Stripe billing integrated

**Phase 2: Enhancement & Scale** - 🚧 **IN PROGRESS** (Q1 2026)
- Improving matching quality and user controls
- Adding export capabilities
- Expanding data sources

**Phase 3: Growth Features** - 📋 **PLANNED** (Q2-Q3 2026)
- Advanced analytics and insights
- Team/organization features
- Integration ecosystem

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

## 🚧 Phase 2: Enhancement & Scale (Q1 2026)

### 2.1 Data Source Expansion
- [ ] [Contracts Finder API Integration](./features/contracts-finder.md) - 🔜 NEXT UP
- [ ] [Scotland Public Contracts](./features/scotland-contracts.md) - 📋 PLANNED
- [ ] [TED (Tenders Electronic Daily)](./features/ted-integration.md) - 📋 PLANNED

### 2.2 Matching Improvements
- [ ] [Multi-Alert Profile Support](./features/multi-alert.md) - 🔜 NEXT UP
- [ ] [Advanced Filters (Value, Region, Buyer Type)](./features/advanced-filters.md) - 📋 PLANNED
- [ ] [Alert Profile Templates](./features/alert-templates.md) - 📋 PLANNED
- [ ] [Match Quality Feedback Loop](./features/feedback-loop.md) - 📋 PLANNED

### 2.3 Export & Integration
- [ ] [Export to Excel/CSV](./features/export-excel.md) - 🔜 NEXT UP
- [ ] [Google Sheets Integration](./features/google-sheets.md) - 📋 PLANNED
- [ ] [Slack Notifications](./features/slack-integration.md) - 📋 PLANNED
- [ ] [Zapier Integration](./features/zapier.md) - 📋 PLANNED

### 2.4 User Experience Enhancements
- [ ] [Alert Profile Editing](./features/alert-editing.md) - 🟡 IN PROGRESS
- [ ] [Tender Detail Page](./features/tender-detail.md) - 📋 PLANNED
- [ ] [Search & Filter Dashboard](./features/dashboard-search.md) - 📋 PLANNED
- [ ] [Email Notification Preferences](./features/notification-preferences.md) - 📋 PLANNED

---

## 📋 Phase 3: Growth Features (Q2-Q3 2026)

### 3.1 Analytics & Insights
- [ ] [Tender Analytics Dashboard](./features/analytics.md) - 📋 PLANNED
- [ ] [Market Insights Report](./features/market-insights.md) - 📋 PLANNED
- [ ] [Competitor Tracking](./features/competitor-tracking.md) - 📋 PLANNED

### 3.2 Team & Organization Features
- [ ] [Team Workspaces](./features/team-workspaces.md) - 📋 PLANNED
- [ ] [Shared Alert Profiles](./features/shared-alerts.md) - 📋 PLANNED
- [ ] [Trade Association Feeds](./features/association-feeds.md) - 📋 PLANNED
- [ ] [Role-Based Access Control](./features/rbac.md) - 📋 PLANNED

### 3.3 Advanced Capabilities
- [ ] [AI Bid Advisor](./features/bid-advisor.md) - 📋 PLANNED
- [ ] [Win Rate Predictions](./features/win-predictions.md) - 📋 PLANNED
- [ ] [Document Analysis](./features/document-analysis.md) - 📋 PLANNED
- [ ] [Calendar Integration](./features/calendar-sync.md) - 📋 PLANNED

### 3.4 Platform Expansion
- [ ] [Mobile App (iOS/Android)](./features/mobile-app.md) - 📋 PLANNED
- [ ] [API for Third-Party Integrations](./features/public-api.md) - 📋 PLANNED
- [ ] [White-Label Solution](./features/white-label.md) - 📋 PLANNED

---

## 🔧 Technical Debt & Infrastructure

### High Priority
- [ ] [Improve Test Coverage](./features/testing.md) - 📋 PLANNED
- [ ] [Performance Optimization](./features/performance.md) - 📋 PLANNED
- [ ] [Error Monitoring & Alerting](./features/monitoring.md) - 📋 PLANNED

### Medium Priority
- [ ] [Database Migration to RDS](./features/db-migration.md) - 📋 PLANNED
- [ ] [CDN for Static Assets](./features/cdn.md) - 📋 PLANNED
- [ ] [Rate Limiting & DDoS Protection](./features/rate-limiting.md) - 📋 PLANNED

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
