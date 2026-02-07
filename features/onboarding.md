# Conversational Onboarding Flow

**Status:** ✅ COMPLETE

**Last Updated:** 2026-02-07

---

## Overview

TenderBot's onboarding is a conversational, multi-step wizard that guides users through setting up their first alert profile. It combines AI-powered suggestions with a chat-like interface to make procurement matching accessible to non-technical users.

---

## User Value

- **Low barrier to entry** - No need to know CPV codes or procurement terminology
- **Instant preview** - See real tender matches before committing to payment
- **Smart suggestions** - AI recommends categories and keywords based on business type
- **Resumable** - Progress saved if user exits and returns later

---

## User Journey

```
Landing → Login → Onboarding (7 steps) → Stripe Checkout → Dashboard
```

### Step-by-Step Flow

**Step 1: Business Type**
- **Question:** "What type of business are you?"
- **Input:** Free-text field
- **Example:** "electrical contractor", "IT consultancy", "facilities management"
- **Backend Call:** `POST /suggest/categories` → Returns CPV categories + keywords
- **State Saved:** `businessType`, `cpvCategories`, `recommendedKeywords`

**Step 2: Categories**
- **Question:** "Which categories are you interested in?"
- **Display:** Multiselect chips with AI-suggested categories
- **Options:** fit-out, interiors, mep, construction, consultancy, landscaping, etc.
- **Interaction:** Click to toggle selection, must select ≥1
- **State Saved:** `categories` (display names), `cpvCategories` (CPV codes)

**Step 3: Regions**
- **Question:** "Which regions do you work in?"
- **Display:** Multiselect chips with UK regions
- **Options:** London, South East, South West, Midlands, North West, North East, Scotland, Wales, Northern Ireland
- **Interaction:** Click to toggle, can select multiple
- **State Saved:** `regions` (array of region names)

**Step 4: Keywords**
- **Question:** "Add keywords to refine your matches"
- **Display:**
  - Pre-filled chips: Base keywords + AI-recommended keywords
  - Text input field to add custom keywords
- **Interaction:**
  - Click chip to remove
  - Type keyword → press Enter to add
  - Keywords auto-deduplicated and normalized
- **Backend Call:** `POST /suggest/keywords` (on mount)
- **State Saved:** `keywords` (array of strings)

**Step 5: Alert Frequency**
- **Question:** "How often would you like to receive alerts?"
- **Options:**
  - **Hourly** - "Get notified immediately"
  - **Daily** - "A summary once a day" (recommended)
  - **Weekly** - "A weekly digest"
- **Interaction:** Single select (radio buttons styled as cards)
- **State Saved:** `alertFrequency` ("hourly" | "daily" | "weekly")

**Step 6: Tender Matches Preview**
- **Question:** "Here's what you'll get - preview your matches"
- **Actions (sequential):**
  1. `POST /customers/identify` - Create/identify customer by email
  2. `POST /customers/{customerId}/alert-profiles` - Create alert profile
  3. `POST /alert-profiles/{alertProfileId}/matches?mode=relaxed` - Get preview matches
- **Display:**
  - 0-5 tender cards with: title, buyer, value, deadline, keywords, confidence
  - If 0 matches: "No matches found - adjust your keywords"
  - Loading spinner during API calls
- **Interaction:**
  - Review matches (read-only, no actions)
  - Click "Continue" to proceed to plan selection
- **State Saved:** `customerId`, `alertProfileId`, `tenderMatches`

**Step 7: Plan Selection**
- **Question:** "Choose your plan"
- **Options:**
  - **Basic** - £10/mo
    - Daily alerts
    - AI summaries
    - Up to 50 tenders/month
  - **Pro** - £20/mo
    - Real-time alerts
    - Advanced AI insights
    - Unlimited tenders
    - Pricing estimates
- **Interaction:** Single select → redirects to Stripe checkout
- **Backend Call:** `POST /billing/checkout` → Returns Stripe URL
- **Redirect:** `window.location.assign(checkoutUrl)`

**Stripe Checkout** (external)
- Stripe hosted page
- Payment form with card details
- On success: redirect to `/success?session_id=...`
- On cancel: redirect to `/cancel`

**Success Page**
- **Backend Call:** `POST /billing/checkout/confirm` with session_id
- **Poll:** `GET /billing/status` until status = "active"
- **Redirect:** `/dashboard` when subscription active

---

## Technical Design

### State Management

**Context:** `OnboardingContext`

**State Schema:**
```typescript
interface OnboardingState {
  currentStep: number;
  businessType: string;
  categories: string[];
  cpvCategories: string[];
  regions: string[];
  keywords: string[];
  recommendedKeywords: string[];
  alertFrequency: "hourly" | "daily" | "weekly";
  customerId?: string;
  alertProfileId?: string;
  tenderMatches?: TenderMatch[];
}
```

**Persistence:**
- Saved to `sessionStorage` on every state change
- Restored on page load (if user refreshes)
- Cleared on successful completion

**Why sessionStorage?**
- Survives page refresh
- Cleared when tab closes (privacy)
- Not shared across tabs (multi-device friendly)

### Step Navigation

**Component:** `OnboardingFlow`

**Router:**
```typescript
const steps = [
  BusinessTypeStep,
  CategoriesStep,
  RegionsStep,
  KeywordsStep,
  FrequencyStep,
  TenderMatchesStep,
  PlanStep
];

const CurrentStep = steps[currentStep];
```

**Navigation Logic:**
```typescript
function handleNext() {
  if (currentStep < steps.length - 1) {
    setCurrentStep(currentStep + 1);
  }
}

function handleBack() {
  if (currentStep > 0) {
    setCurrentStep(currentStep - 1);
  }
}
```

**Validation:**
- Each step validates input before allowing "Continue"
- Business type: ≥3 characters
- Categories: ≥1 selected
- Regions: ≥1 selected
- Keywords: ≥1 keyword
- Frequency: one selected
- Matches: alert profile created successfully

### AI Suggestions

**Category Suggestions:**

```http
POST /suggest/categories
Content-Type: application/json

{
  "business_type": "electrical contractor"
}

Response:
{
  "recommended_categories": [
    { "name": "electrical", "cpv_code": "45310000", "confidence": 0.95 },
    { "name": "construction", "cpv_code": "45000000", "confidence": 0.80 }
  ]
}
```

**Keyword Suggestions:**

```http
POST /suggest/keywords
Content-Type: application/json

{
  "business_type": "electrical contractor",
  "categories": ["electrical", "construction"],
  "cpv_codes": ["45310000", "45000000"]
}

Response:
{
  "recommended_keywords": [
    "electrical installation",
    "wiring",
    "lighting",
    "power systems",
    "electrical maintenance"
  ],
  "confidence": 0.90
}
```

**Fallback Behavior:**
- If API fails → use static default suggestions
- If no suggestions → show empty state, allow custom input
- Cache suggestions per business type (5-minute TTL)

### Tender Preview (Relaxed Mode)

**Why Relaxed Mode?**
- New users have no delivery history (no `last_delivered_at`)
- Exact mode would be too restrictive (might return 0 results)
- Relaxed mode gives users a taste of what to expect

**API Call:**
```http
POST /alert-profiles/{alertProfileId}/matches?mode=relaxed
Content-Type: application/json

{
  "cpv_codes": ["45310000"],
  "keywords": ["electrical", "wiring"],
  "regions": ["South East", "London"]
}

Response:
{
  "matches": [
    {
      "id": "uuid",
      "title": "Electrical Installation Services",
      "summary": "...",
      "buyer_name": "Example Council",
      "deadline": "2024-03-15",
      "estimated_value": 75000,
      "confidence": 0.82,
      "keywords": ["electrical", "installation"]
    }
  ],
  "candidate_count": 120,
  "match_count": 5
}
```

**Display Logic:**
- Show top 5 matches (or fewer if <5 found)
- If 0 matches: Show friendly message + suggest editing keywords
- Sort by confidence DESC

---

## UI/UX Design

### Chat-Like Interface

**Message Types:**
- **Assistant message** - White bubble on left, TenderBot avatar
- **User message** - Blue bubble on right

**Example Conversation:**

```
[TenderBot Avatar]
┌───────────────────────────────┐
│ What type of business are    │
│ you?                          │
└───────────────────────────────┘

                    ┌───────────────┐
                    │ Electrical    │
                    │ contractor    │
                    └───────────────┘

[TenderBot Avatar]
┌───────────────────────────────┐
│ Great! I recommend these      │
│ categories for you:           │
│                               │
│ [electrical] [construction]   │
│ [mep] [maintenance]           │
└───────────────────────────────┘
```

**Interaction Patterns:**
- Smooth scroll to new message
- Typing indicator while API loading
- Auto-advance on input completion
- Back button always visible (except step 1)

### Mobile Responsiveness

**Breakpoints:**
- Mobile: <768px - Full-screen wizard, stack chips vertically
- Tablet: 768-1024px - Centered wizard, 2-column chips
- Desktop: >1024px - Centered wizard with max-width 600px

**Touch Optimization:**
- Large tap targets (44×44px minimum)
- No hover-only interactions
- Swipe to navigate (future enhancement)

### Accessibility

**Keyboard Navigation:**
- Tab through options
- Enter to select
- Arrow keys to navigate chips

**Screen Reader:**
- ARIA labels on all interactive elements
- Live region announcements for state changes
- Semantic HTML (headings, lists, buttons)

**Focus Management:**
- Auto-focus input on step mount
- Focus trap within modal/wizard

---

## Auth Integration

### Flow with Authentication

**Case 1: Anonymous User**
1. User lands on `/onboarding`
2. Completes steps 1-6 (no login required)
3. Step 6: API calls require Auth0 token
4. Redirect to `/login` with `?returnTo=/onboarding?resume=1`
5. After login, return to onboarding with state restored

**Case 2: Logged-In User**
1. User completes onboarding uninterrupted
2. Email pre-filled from Auth0 profile

**State Preservation:**
- Before redirect: `sessionStorage.setItem('onboardingState', JSON.stringify(state))`
- After login: `const state = JSON.parse(sessionStorage.getItem('onboardingState'))`

### Token Handling

**API Wrapper:**
```typescript
async function apiFetch(url: string, options: RequestInit) {
  const token = await auth0.getAccessToken();
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`
    }
  });
}
```

---

## Success Metrics

**Completion Rate:**
- 80%+ users complete all 7 steps
- <10% drop-off per step
- 90%+ conversion from step 6 → Stripe checkout

**Time to Complete:**
- Median: 2-3 minutes
- 90th percentile: <5 minutes

**Match Quality:**
- 80%+ users see ≥1 match in preview
- Avg 3-5 matches shown
- <5% users see 0 matches

**API Success:**
- 99%+ success rate for all API calls
- <2 sec average API response time

---

## Future Enhancements

### 1. Progressive Disclosure

**Goal:** Reduce cognitive load

**Approach:**
- Show only essential fields initially
- "Advanced options" expander for power users
- Value range filter
- Buyer type filter

### 2. Onboarding Templates

**Goal:** Faster setup for common industries

**Templates:**
- "IT Services Provider"
- "Construction Contractor"
- "Facilities Management"

**Each template includes:**
- Pre-filled business type
- Pre-selected categories
- Pre-selected keywords

### 3. Match Quality Score

**Goal:** Help users understand their profile strength

**Display:**
- "Your profile is 85% likely to find good matches"
- Green/yellow/red indicator
- Tips to improve (e.g., "Add more keywords")

### 4. Multi-Profile Onboarding

**Goal:** Let users create >1 alert profile during signup

**Flow:**
- After step 7, "Create another alert profile?"
- Clone state and modify
- Pay once, get multiple profiles

---

## File Locations

**Frontend:**
- Main Flow: `/signup/app/onboarding/OnboardingFlow.tsx`
- Steps: `/signup/app/onboarding/steps/*.tsx`
- Context: `/signup/contexts/OnboardingContext.tsx`
- API Calls: `/signup/lib/api.ts`

**Backend:**
- Suggestions: `/backend/tenderbot/api/routers/suggestions_router.py`
- Customers: `/backend/tenderbot/api/routers/customers_router.py`
- Alert Profiles: `/backend/tenderbot/api/routers/alert_profiles_router.py`

---

## References

- Auth0 SPA SDK: https://auth0.com/docs/libraries/auth0-spa-js
- Radix UI (components): https://www.radix-ui.com/
- React Hook Form: https://react-hook-form.com/
