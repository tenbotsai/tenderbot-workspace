# Alert Delivery System

**Status:** ✅ COMPLETE

**Last Updated:** 2026-02-07

---

## Overview

The alert delivery system automatically sends email notifications to users when new tender matches are found. It respects user preferences for frequency (hourly, daily, weekly) and tracks delivery history for audit and preview.

---

## User Value

- **Timely notifications** - Never miss a deadline with configurable alert frequency
- **Beautiful emails** - Clean, mobile-responsive HTML templates
- **Delivery transparency** - View history of all past alerts in dashboard
- **Email preview** - See exactly what was sent without checking inbox

---

## Technical Design

### Architecture

```
Prefect Scheduler → Schedule Flow → Matching Flow → Email Task → Email Service
                         ↓                               ↓
                   Alert Profiles                  Delivery History
```

### Alert Scheduling Flow

**Flow:** `schedule_alerts_flow`

**Trigger:** Cron schedule (every 15 minutes)

**Logic:**

1. **Find Due Profiles**
   ```sql
   SELECT * FROM alert_profiles
   WHERE status = 'active'
   AND (
     -- Hourly: last delivered >55min ago
     (alert_frequency = 'hourly' AND last_delivered_at < NOW() - INTERVAL '55 minutes')

     OR

     -- Daily: last delivered >23.5 hours ago
     (alert_frequency = 'daily' AND last_delivered_at < NOW() - INTERVAL '23 hours 30 minutes')

     OR

     -- Weekly: last delivered >6.9 days ago
     (alert_frequency = 'weekly' AND last_delivered_at < NOW() - INTERVAL '6 days 21 hours')
   );
   ```

2. **Enqueue Matching Flows**
   - For each due profile, spawn `matching_flow`
   - Matching flow calls `generate_matches_task` + `email_sending_task`
   - Runs in parallel (up to 10 concurrent flows)

3. **Track Results**
   - Count profiles queued
   - Count matches generated
   - Log summary

**Lookahead Window:** 60 minutes (default)
- Ensures alerts sent within 5 minutes of due time
- Prevents missed alerts during downtime

### Email Sending Task

**Task:** `email_sending_task`

**Input:**
- `alert_profile_id` - Which profile to send
- `tender_match_ids` - List of match IDs (from generate_matches_task)

**Steps:**

1. **Fetch Data**
   ```python
   alert_profile = await alert_profiles_repo.get(alert_profile_id)
   customer = await customers_repo.get(alert_profile.customer_id)
   matches = await matches_repo.get_by_ids(tender_match_ids)
   ```

2. **Duplicate Check**
   ```python
   existing = await delivery_history_repo.find_by_match_ids(
       alert_profile_id, tender_match_ids
   )
   if existing:
       return {"status": "duplicate", "delivery_id": existing.id}
   ```

3. **Render Email**
   ```python
   subject = f"{len(matches)} new tender {'matches' if len(matches) != 1 else 'match'} for {alert_profile.business_type} Alerts"

   html_body = email_renderer.render(
       matches=matches,
       dashboard_url="https://app.tenderbot.com/dashboard"
   )

   text_body = email_renderer.render_text(matches)
   ```

4. **Send Email**
   ```python
   response = await email_client.send_tender_alert(
       to_email=customer.email,
       subject=subject,
       html_body=html_body,
       text_body=text_body
   )
   ```

5. **Track Delivery**
   ```python
   delivery = await delivery_history_repo.create(
       alert_profile_id=alert_profile_id,
       match_ids=tender_match_ids,
       subject=subject,
       html_body=html_body,
       text_body=text_body,
       status="sent",
       provider_response_id=response.message_id,
       delivered_at=datetime.utcnow()
   )
   ```

6. **Update Alert Profile**
   ```python
   await alert_profiles_repo.update(
       alert_profile_id,
       last_delivered_at=datetime.utcnow()
   )
   ```

7. **Mark Matches as Delivered**
   ```python
   await matches_repo.mark_as_delivered(
       tender_match_ids,
       delivered_at=datetime.utcnow()
   )
   ```

**Error Handling:**
- Email send failure → retry 3 times with 60-second delay
- Parse error → log and skip
- No matches → save delivery with status "no_matches", don't send email
- Dev/test mode → save delivery with status "skipped_dev", don't send email

**Return Value:**
```python
{
    "delivery_id": "uuid",
    "status": "sent" | "failed" | "no_matches" | "skipped_dev" | "duplicate",
    "match_count": 5,
    "delivered_at": "2024-01-15T10:00:00Z"
}
```

---

## Email Template

### HTML Template Structure

**Layout:**
- Header: TenderBot logo + "Your Tender Alerts"
- Body: Tender match cards (stacked)
- Footer: Dashboard link + Unsubscribe

**Tender Card:**

```
┌─────────────────────────────────────┐
│ [Title]                             │
│ [Summary in 1-2 sentences]          │
│                                     │
│ 📍 Region: South East               │
│ 🏢 Buyer: Example Council           │
│ 💷 Value: £50,000 - £100,000        │
│ ⏰ Deadline: 15 Feb 2024            │
│                                     │
│ 🏷️ CPV: 72000000, 72200000         │
│ 🔑 Keywords: software, IT           │
│                                     │
│ [View Full Tender →]                │
└─────────────────────────────────────┘
```

**Styling:**
- Inline CSS (for email client compatibility)
- Mobile-responsive (media queries)
- Primary color: `#0066cc` (TenderBot blue)
- Font: system fonts (Arial, Helvetica, sans-serif)

### Text Template (Fallback)

```
TENDERBOT - Your Tender Alerts

You have 5 new tender matches:

1. IT Services Procurement
   Example Council | £50,000 - £100,000 | Deadline: 15 Feb 2024
   Summary: Provision of cloud infrastructure and support services.
   https://www.find-tender.service.gov.uk/Notice/abc123

2. [...]

---
View all matches: https://app.tenderbot.com/dashboard
Manage alerts: https://app.tenderbot.com/dashboard/alerts
```

### Template Variables

| Variable | Example | Source |
|----------|---------|--------|
| `{{ matches }}` | Array of tender match objects | Database query |
| `{{ dashboard_url }}` | `https://app.tenderbot.com/dashboard` | Config |
| `{{ logo_url }}` | `https://app.tenderbot.com/logo.png` | Config |
| `{{ unsubscribe_url }}` | `https://app.tenderbot.com/unsubscribe?token=...` | Generated |

---

## Delivery Tracking

### Database Model

**Table:** `delivery_history`

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| alert_profile_id | UUID | FK to alert_profiles |
| match_ids | UUID[] | Array of tender_match IDs |
| subject | TEXT | Email subject line |
| html_body | TEXT | Full HTML content |
| text_body | TEXT | Plain text fallback |
| status | TEXT | sent, failed, no_matches, skipped_dev, duplicate |
| provider_response_id | TEXT | Email service message ID |
| delivered_at | TIMESTAMP | When email was sent (UTC) |
| created_at | TIMESTAMP | Record creation time |

**Indexes:**
- `alert_profile_id` (B-tree) - For user's delivery history
- `delivered_at` (B-tree) - For date range queries
- GIN on `match_ids` - For duplicate detection

### API Endpoints

**List Deliveries:**
```http
GET /delivery-history?limit=20&offset=0

Response:
{
  "deliveries": [
    {
      "id": "uuid",
      "alert_profile_id": "uuid",
      "subject": "5 new tender matches for IT Services Alerts",
      "status": "sent",
      "match_count": 5,
      "delivered_at": "2024-01-15T10:00:00Z"
    }
  ],
  "total": 150
}
```

**Get Email Preview:**
```http
GET /delivery-history/{delivery_id}/preview

Response:
Content-Type: text/html

<!DOCTYPE html>
<html>
  <!-- Full HTML email content -->
</html>
```

### Dashboard Integration

**Email History Tab:**
- Two-column layout: list (left) + preview (right)
- Status badges with colors:
  - `sent` → Green
  - `failed` → Red
  - `no_matches` → Amber
  - `skipped_dev` → Blue
  - `duplicate` → Gray
- Click delivery → load HTML preview in iframe
- Pagination: 20 per page

---

## Email Service Integration

### Current: Generic Email API

**Configuration:**
- Base URL: `https://api.emailservice.com/v1`
- API Key: Environment variable `EMAIL_API_KEY`
- Sender: `alerts@tenderbot.com`

**Endpoints Used:**

**Send Email:**
```http
POST /messages
Authorization: Bearer {api_key}
Content-Type: application/json

{
  "from": "alerts@tenderbot.com",
  "to": "user@example.com",
  "subject": "5 new tender matches",
  "html": "<html>...</html>",
  "text": "Plain text fallback"
}

Response:
{
  "id": "msg_abc123",
  "status": "queued"
}
```

**Provider Options:**
- **Resend** (current) - Developer-friendly, reasonable pricing
- **SendGrid** - Enterprise, high volume
- **AWS SES** - Cheapest, requires warm-up
- **Postmark** - Best deliverability

### Deliverability Best Practices

**SPF & DKIM:**
- Configure DNS records for `alerts@tenderbot.com`
- DKIM signature in email headers
- SPF record: `v=spf1 include:emailservice.com ~all`

**Unsubscribe Link:**
- Required by CAN-SPAM Act
- One-click unsubscribe (List-Unsubscribe header)
- Link in email footer

**Bounce Handling:**
- Monitor bounce webhook from email provider
- Hard bounces → mark customer as undeliverable
- Soft bounces → retry up to 3 times

**Spam Prevention:**
- Avoid spam trigger words ("free", "guaranteed")
- Keep HTML clean (no excessive styling)
- Balance text/image ratio
- Test with Mail-Tester.com

---

## Alert Frequency Options

| Frequency | Description | Use Case |
|-----------|-------------|----------|
| **Hourly** | Alerts sent every hour (if new matches) | Active bidders, high-value sectors |
| **Daily** | Alerts sent once per day (morning) | Most users, balanced approach |
| **Weekly** | Alerts sent once per week (Monday AM) | Casual users, low-volume sectors |

**Timing Preferences (PLANNED):**
- Allow users to specify preferred time (e.g., "8 AM")
- Respect timezone (currently UTC only)

**Batch Threshold (PLANNED):**
- Don't send if <3 new matches (wait for next cycle)
- Configurable per user

---

## Success Metrics

**Deliverability:**
- 99%+ delivery rate
- <1% bounce rate
- <0.1% spam complaints

**Engagement:**
- 40%+ open rate
- 15%+ click-through rate (to dashboard)
- <2% unsubscribe rate

**Performance:**
- <10 sec from match to send
- 100% of scheduled alerts sent on time
- Zero missed alerts due to system errors

---

## Future Enhancements

### 1. In-App Notifications

**Goal:** Real-time alerts in dashboard (no email required)

**Implementation:**
- WebSocket connection to backend
- Push notification API (Web Push)
- Toast notification in dashboard
- Notification center with unread count

**User Control:**
- Toggle email vs in-app vs both
- Granular settings per alert profile

### 2. SMS Alerts (High-Value Tenders)

**Goal:** Critical deadline reminders

**Trigger:** Tender value >£500K + deadline <48 hours
**Provider:** Twilio
**Message:** "Urgent: £750K tender deadline in 24hrs. View: https://app.tenderbot.com/..."

### 3. Slack Integration

**Goal:** Send alerts to Slack channels

**Use Case:** Teams collaborating on bids

**Implementation:**
- OAuth app for workspace installation
- Configurable channel per alert profile
- Rich message format with action buttons

### 4. Digest Mode

**Goal:** Single email with all matches (vs one per alert profile)

**Format:**
- "Daily Digest: 15 new tenders across 3 alert profiles"
- Grouped by alert profile
- Single unsubscribe for all

### 5. Smart Send Time

**Goal:** Optimize delivery time for each user

**Approach:**
- Track when user opens emails
- ML model predicts best send time
- Schedule alerts accordingly

---

## File Locations

**Backend:**
- Scheduler Flow: `/backend/tenderbot/tasks/flows/schedule_alerts_flow.py`
- Email Task: `/backend/tenderbot/tasks/email_sending_task.py`
- Email Client: `/backend/tenderbot/services/email_client.py`
- Email Renderer: `/backend/tenderbot/services/email_renderer.py`
- Delivery Repo: `/backend/tenderbot/data/delivery_history_repo.py`
- Router: `/backend/tenderbot/api/routers/delivery_history_router.py`

**Frontend:**
- Email History Tab: `/signup/app/dashboard/EmailHistoryTab.tsx`
- Delivery Preview: `/signup/components/DeliveryPreview.tsx`

---

## References

- CAN-SPAM Act: https://www.ftc.gov/business-guidance/resources/can-spam-act-compliance-guide-business
- Email Best Practices: https://resend.com/docs/send-with-resend/email-best-practices
- Web Push API: https://developer.mozilla.org/en-US/docs/Web/API/Push_API
