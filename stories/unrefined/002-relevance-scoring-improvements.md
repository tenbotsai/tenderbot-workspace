---
id: 002
title: Improve Relevance Scoring Logic and User Control
status: unrefined
priority: medium
labels: [matching, llm, ux]
estimate: unknown
created: 2026-02-07
updated: 2026-02-07
---

# User Story

As a TenderBot user,
I want the relevance score to reflect my personal preferences (e.g., geography vs content match),
So that the most relevant tenders appear at the top of my feed.

# Problem Statement

Current relevance scores are purely driven by the LLM without specific instructions on how to weight different factors:

- **Text content match** vs **Geographic proximity** (NUTS codes)
- **CPV code alignment** vs **Keyword density**
- **Contract value** vs **Buyer type**

We don't know:
1. How the LLM currently weighs these factors
2. Whether users prefer different weightings
3. If scoring should be configurable per user

**Questions to answer:**
- Is a tender with high text content match but distant geography more relevant than one with weaker content match but close geography?
- Should this be a system-level decision or user preference?
- If user preference, how do we capture it?

# Proposed Solution (High-Level)

Two possible approaches:

**Option A: Enhanced LLM Prompt**
- Give LLM explicit scoring rubric (e.g., "Weight geography 30%, content 50%, value 20%")
- Test different rubrics to find optimal balance

**Option B: User Preference Controls**
- Let users adjust scoring weights in settings
- Pass preferences to LLM in prompt
- Provide presets: "Prioritize Location", "Prioritize Relevance", "Balanced"

# Acceptance Criteria

- [ ] Understand current LLM scoring behavior
- [ ] Define default scoring rubric
- [ ] Determine if user control is needed
- [ ] Implement chosen approach
- [ ] Validate scoring improvements with real users

# Technical Context

## Current State
- LLM scoring: `/backend/tenderbot/tasks/generate_matches_task.py`
- Prompt doesn't specify scoring methodology
- Confidence score is 0.0-1.0 but weighting is opaque

## Proposed Changes
- Update LLM prompt with explicit scoring instructions
- Optionally: Add user preferences to alert_profiles table
- Optionally: Create settings UI for scoring preferences

## File Locations
- Matching task: `/backend/tenderbot/tasks/generate_matches_task.py`
- Alert profiles: `/backend/tenderbot/data/alert_profiles_repo.py`
- Settings UI: `/signup/app/dashboard/SettingsTab.tsx`

# Open Questions

- [ ] What factors matter most to users? (Need user research)
- [ ] Should scoring be configurable or one-size-fits-all?
- [ ] How do we test different scoring approaches?
- [ ] Do we need A/B testing infrastructure?
- [ ] Can we use user actions (interested/dismiss) to learn preferences?

# Dependencies

None

# Notes

Requires user research and experimentation to determine best approach. May need to test with real users before implementing.
