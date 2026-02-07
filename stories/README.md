# TenderBot Stories

This directory contains user stories for TenderBot development, organized by status.

## Directory Structure

```
/stories/
  /unrefined/     - High-level stories that need more context and breakdown
  /refined/       - Fully detailed stories ready for implementation
  /in-progress/   - Stories currently being worked on
  /done/          - Completed stories (for reference)
```

## Story Lifecycle

```
unrefined → refined → in-progress → done
```

### Status Definitions

- **unrefined**: High-level capture of the problem and desired outcome. Missing implementation details, may have open questions.
- **refined**: Fully detailed with context, acceptance criteria, technical approach, and all questions answered. Ready for a coding agent to implement.
- **in-progress**: Currently being implemented. Files move here when work starts.
- **done**: Implementation complete, tested, and merged. Files move here for historical reference.

## Story Template

Each story follows this format:

```markdown
---
id: 001
title: Short descriptive title
status: unrefined|refined|in-progress|done
priority: high|medium|low
labels: [category1, category2]
estimate: unknown|small|medium|large
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# User Story
As a [user type],
I want [goal],
So that [benefit].

# Problem Statement
[Detailed explanation]

# Proposed Solution (High-Level)
[Overview of approach]

# Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

# Technical Context
## Current State
## Proposed Changes
## File Locations

# Open Questions
- [ ] Question 1
- [ ] Question 2

# Dependencies
[Other stories or requirements]

# Notes
[Additional context]
```

## Working with Stories

### For Humans

1. **Creating a story**: Add to `/unrefined/` with basic problem and outcome
2. **Refining a story**: Move to `/refined/` when all questions answered and ready to implement
3. **Starting work**: Move to `/in-progress/` when you begin implementation
4. **Completing**: Move to `/done/` when merged and deployed

### For AI Coding Agents

1. **Reading stories**: Check `/refined/` for implementation-ready work
2. **Getting context**: Read the entire story file for complete context
3. **Asking questions**: If story is unrefined, ask for refinement before implementing
4. **Updating status**: Update the story file as you progress through implementation

## Current Stories

### Unrefined (9)

1. **001-keyword-extraction-matching.md** - Extract keywords from tenders using LLM batch API for better matching
2. **002-relevance-scoring-improvements.md** - Improve LLM scoring instructions and potentially add user controls
3. **003-comprehensive-testing-strategy.md** - Add full test coverage for onboarding and dashboard with mocking strategy
4. **004-staging-environment.md** - Set up staging environment for safe E2E testing
5. **005-email-provider-integration.md** - Integrate email provider API (Resend/SendGrid/etc) to send alerts
6. **006-automated-email-testing.md** - Automated visual regression tests for email rendering
7. **007-improve-match-descriptions.md** - Generate specific relevance explanations instead of generic summaries
8. **008-fix-logo-rendering.md** - Fix logo to match prototype appearance
9. **009-preserve-onboarding-chat-history.md** - Preserve chat messages across auth redirect

### Refined (0)

None yet - stories need refinement

### In Progress (0)

None yet

### Done (0)

None yet

## Prioritization

Stories are prioritized based on:
1. **User impact** - Does this fix a blocker or add critical value?
2. **Dependencies** - Do other stories depend on this?
3. **Risk** - Does this reduce technical risk or enable other work?
4. **Effort** - Quick wins vs larger efforts

### Current Priorities

**High Priority:**
- #001 - Keyword extraction (core matching improvement)
- #003 - Testing strategy (enables confident development)
- #004 - Staging environment (unblocks testing)
- #005 - Email provider (blocking user value)

**Medium Priority:**
- #002 - Relevance scoring (quality improvement)
- #006 - Email testing (quality assurance)
- #007 - Match descriptions (UX improvement)
- #009 - Onboarding history bug (UX issue)

**Low Priority:**
- #008 - Logo rendering (visual polish)

## Refinement Process

To refine a story:

1. **Read the unrefined version** to understand the problem
2. **Ask clarifying questions** about requirements, constraints, priorities
3. **Investigate current implementation** to understand what exists
4. **Design the solution** with specific technical approach
5. **Answer all open questions** with concrete decisions
6. **Break down into tasks** if story is too large
7. **Update the story file** with all new information
8. **Move to /refined/** when complete and ready for implementation

## Notes

- Stories are version controlled in git - track changes over time
- Use descriptive commit messages when updating stories
- Link to stories from PRs/commits when implementing
- Keep stories focused - split large stories into multiple smaller ones
