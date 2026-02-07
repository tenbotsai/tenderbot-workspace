---
id: 009
title: Preserve Onboarding Chat History After Authentication
status: unrefined
priority: medium
labels: [onboarding, bug, frontend, ux]
estimate: small
created: 2026-02-07
updated: 2026-02-07
---

# User Story

As a user going through onboarding,
I want to see my previous chat history when I return after authenticating,
So that the conversation feels continuous and I don't lose context.

# Problem Statement

When a user completes the first few onboarding steps and reaches the authentication gate:
1. User progresses through onboarding steps 1-4
2. User reaches step 5 which requires authentication
3. User redirects to login
4. User authenticates successfully
5. User returns to onboarding
6. **BUG:** Chat history is wiped - previous messages are gone

**Expected Behavior:**
- Chat history preserved across authentication redirect
- User sees all previous assistant and user messages
- Conversation feels continuous
- Current state (answers) is preserved (this already works)

**Current Behavior:**
- State (answers) is preserved in sessionStorage ✅
- Chat message history is lost ❌

# Proposed Solution (High-Level)

**Store chat history alongside state:**

Current: Only store answers in sessionStorage
```typescript
sessionStorage.setItem('onboardingState', JSON.stringify({
  currentStep: 3,
  businessType: "electrical contractor",
  categories: ["electrical", "construction"],
  // ... other answers
}));
```

Proposed: Also store message history
```typescript
sessionStorage.setItem('onboardingState', JSON.stringify({
  currentStep: 3,
  businessType: "electrical contractor",
  categories: ["electrical", "construction"],
  // ... other answers
  messageHistory: [
    { role: 'assistant', content: 'What type of business are you?' },
    { role: 'user', content: 'electrical contractor' },
    { role: 'assistant', content: 'Great! Which categories are you interested in?' },
    // ...
  ]
}));
```

**On return from auth:**
1. Restore state from sessionStorage ✅ (already works)
2. Restore message history from sessionStorage (needs implementation)
3. Render all previous messages
4. Continue from current step

# Acceptance Criteria

- [ ] Chat message history preserved across auth redirect
- [ ] All previous messages display when user returns
- [ ] Message order is correct
- [ ] Both assistant and user messages show
- [ ] Works for all onboarding steps
- [ ] No duplicate messages

# Technical Context

## Current State
- Onboarding flow: `/signup/app/onboarding/OnboardingFlow.tsx`
- Context: `/signup/contexts/OnboardingContext.tsx`
- State persistence: sessionStorage
- Answers preserved ✅
- Message history not preserved ❌

## Proposed Changes
- Add `messageHistory` array to OnboardingContext state
- Update sessionStorage save/restore to include messages
- Render message history on component mount
- Ensure messages don't duplicate on step navigation

## File Locations
- Onboarding flow: `/signup/app/onboarding/OnboardingFlow.tsx`
- Context: `/signup/contexts/OnboardingContext.tsx`
- Auth callback: `/signup/app/auth/callback/page.tsx`

# Open Questions

- [ ] Where is the message state currently stored? (component state?)
- [ ] Is message history a simple array or more complex structure?
- [ ] Are there any side effects of restoring messages? (re-renders, API calls)
- [ ] Should we clear message history after successful completion?

# Dependencies

None

# Notes

This should be a straightforward fix - extending the existing state persistence to include message history. Likely a few hours of work.

**Investigation Needed:**
- Find where messages are currently stored in component state
- Understand the message data structure
- Test that restored messages render correctly
