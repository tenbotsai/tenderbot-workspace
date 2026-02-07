---
id: 007
title: Improve Match Descriptions to Show Specific Relevance
status: unrefined
priority: medium
labels: [matching, llm, ux]
estimate: unknown
created: 2026-02-07
updated: 2026-02-07
---

# User Story

As a TenderBot user,
I want match descriptions to explain specifically why a tender is relevant to me,
So that I can quickly assess if it's worth pursuing.

# Problem Statement

Current match descriptions are too generic:
- "This tender matches because it belongs to the category you are interested in"
- Doesn't explain the specific connection to user's profile
- Lacks compelling detail about relevance

**Users Need:**
- Specific reasons why the tender matches their business
- Highlight which keywords/categories triggered the match
- Show alignment with their stated preferences
- Make it immediately clear why they should care

# Proposed Solution (High-Level)

Enhance the LLM prompt to generate more specific, compelling descriptions:

**Current:** Generic category-based explanation
**Desired:** Specific relevance explanation

**Examples:**

❌ **Bad:** "This tender matches because it belongs to the construction category you are interested in"

✅ **Good:** "This electrical installation tender from Manchester City Council matches your profile for 'electrical contractor' work in the North West. Keywords: wiring, lighting systems, power distribution."

✅ **Good:** "Perfect match for your IT consultancy services. The tender seeks cloud infrastructure expertise, specifically mentioning AWS and DevOps - both in your keyword list."

**Approach:**
- Update LLM prompt to include user's business type and keywords explicitly
- Ask LLM to identify specific overlaps
- Format: "This [tender type] from [buyer] matches your [business type] profile because [specific reasons]"
- Include matched keywords/CPV codes in description

# Acceptance Criteria

- [ ] Match descriptions mention specific keywords that triggered match
- [ ] Descriptions reference user's business type
- [ ] Descriptions explain the connection clearly
- [ ] Users report improved relevance understanding
- [ ] Match summaries remain concise (2-3 sentences)

# Technical Context

## Current State
- LLM generates summaries in matching task
- Prompt: `/backend/tenderbot/tasks/generate_matches_task.py`
- Summary field in `tender_matches` table
- Displayed in dashboard and emails

## Proposed Changes
- Update LLM prompt with explicit instructions for relevance explanation
- Pass user's business type and keywords to prompt
- Update summary field format/length if needed
- Test with real examples

## File Locations
- Matching task: `/backend/tenderbot/tasks/generate_matches_task.py`
- Dashboard display: `/signup/app/dashboard/TenderCard.tsx`
- Email template: `/backend/tenderbot/services/email_renderer.py`

# Open Questions

- [ ] What's the ideal description length? (current: 200 chars)
- [ ] Should we show matched keywords as tags separately?
- [ ] Do we need a longer "why this matches" section in tender detail view?
- [ ] How do we test prompt improvements systematically?
- [ ] Can we A/B test different description styles?

# Dependencies

None

# Notes

This is a prompt engineering task - relatively quick to implement but requires iteration to get right.

**Testing Approach:**
1. Create 10 real tender examples
2. Generate descriptions with new prompt
3. Compare with current descriptions
4. Gather feedback from users/stakeholders
5. Iterate on prompt
