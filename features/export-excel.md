# Export to Excel/CSV

**Status:** 📋 PLANNED (Q1 2026)

**Priority:** 🔜 NEXT UP

**Last Updated:** 2026-02-07

---

## Overview

Allow users to export tender matches, saved tenders, and delivery history to Excel (.xlsx) or CSV formats for offline analysis, sharing with colleagues, or importing into other systems.

---

## User Value

- **Offline analysis** - Work with tender data in Excel/Google Sheets
- **Sharing** - Send tender lists to colleagues or clients
- **Record keeping** - Archive matches for compliance/audit
- **Integration** - Import into CRM, project management, or bidding tools

---

## User Stories

**As a bid consultant:**
- I want to export my client's tender matches to Excel
- So I can add my own notes and share with the client for review

**As a business owner:**
- I want to export all saved tenders for the past month
- So I can analyze which sectors have the most opportunities

**As a trade association:**
- I want to export all recent matches across multiple alert profiles
- So I can share a weekly digest spreadsheet with our members

---

## Feature Specification

### Export Options

**What Can Be Exported:**

1. **Tender Matches (Feed)**
   - Current feed view (filtered/sorted)
   - All matches for selected alert profile
   - Date range: last 7 days, 30 days, 90 days, all time

2. **Saved Tenders**
   - All saved tenders
   - Date range filter

3. **Delivery History**
   - Email delivery log
   - Includes match counts and status

### Export Formats

**Excel (.xlsx)**
- Multi-sheet workbook (if exporting multiple entities)
- Formatted headers (bold, colored)
- Column widths auto-sized
- Hyperlinks clickable
- Freeze top row (header)

**CSV (.csv)**
- Plain text, comma-separated
- UTF-8 encoding
- Quoted strings
- Standard Excel-compatible format

---

## Technical Design

### Architecture

**Option A: Client-Side Export (Recommended)**

```
Frontend → Fetch All Data → Generate File → Download
```

**Pros:**
- No backend changes needed
- Instant download (no API wait time)
- Works offline (if data cached)

**Cons:**
- Limited to data already loaded in UI
- Large datasets may cause browser slowdown

**Option B: Server-Side Export**

```
Frontend → Request Export → Backend Generates File → Stream to Client
```

**Pros:**
- Can export full dataset (not limited by pagination)
- Faster for large exports
- Can add complex formatting

**Cons:**
- Additional backend work
- File storage/cleanup required
- More complex error handling

**Decision: Start with Option A (client-side), upgrade to Option B if needed**

### Frontend Implementation

**Libraries:**

- **Excel:** `exceljs` (16KB gzipped, full Excel support)
- **CSV:** Built-in `Blob` + `URL.createObjectURL` (no library needed)

**Example Code (Excel):**

```typescript
import ExcelJS from 'exceljs';

async function exportToExcel(matches: TenderMatch[]) {
  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet('Tender Matches');

  // Add headers
  worksheet.columns = [
    { header: 'Title', key: 'title', width: 40 },
    { header: 'Buyer', key: 'buyer_name', width: 30 },
    { header: 'Region', key: 'region', width: 15 },
    { header: 'Value (GBP)', key: 'estimated_value', width: 15 },
    { header: 'Deadline', key: 'deadline', width: 12 },
    { header: 'Confidence', key: 'confidence', width: 12 },
    { header: 'Keywords', key: 'keywords', width: 30 },
    { header: 'CPV Codes', key: 'cpv_codes', width: 20 },
    { header: 'URL', key: 'tender_url', width: 50 }
  ];

  // Style header row
  worksheet.getRow(1).font = { bold: true };
  worksheet.getRow(1).fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FF0066CC' }
  };

  // Add data rows
  matches.forEach(match => {
    worksheet.addRow({
      title: match.title,
      buyer_name: match.buyer_name,
      region: match.region,
      estimated_value: match.estimated_value || 'Not disclosed',
      deadline: new Date(match.deadline).toLocaleDateString('en-GB'),
      confidence: `${Math.round(match.confidence * 100)}%`,
      keywords: match.keywords.join(', '),
      cpv_codes: match.cpv_codes.join(', '),
      tender_url: match.tender_url
    });
  });

  // Make URL column hyperlinks
  worksheet.getColumn('tender_url').eachCell({ includeEmpty: false }, (cell, rowNumber) => {
    if (rowNumber > 1) {
      cell.value = {
        text: 'View Tender',
        hyperlink: cell.value as string
      };
      cell.font = { color: { argb: 'FF0066CC' }, underline: true };
    }
  });

  // Generate file
  const buffer = await workbook.xlsx.writeBuffer();
  const blob = new Blob([buffer], {
    type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  });

  // Trigger download
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `tenderbot-matches-${new Date().toISOString().split('T')[0]}.xlsx`;
  link.click();
  URL.revokeObjectURL(url);
}
```

**CSV Example:**

```typescript
function exportToCSV(matches: TenderMatch[]) {
  const headers = ['Title', 'Buyer', 'Region', 'Value (GBP)', 'Deadline', 'Confidence', 'Keywords', 'CPV Codes', 'URL'];

  const rows = matches.map(match => [
    match.title,
    match.buyer_name,
    match.region,
    match.estimated_value || 'Not disclosed',
    new Date(match.deadline).toLocaleDateString('en-GB'),
    `${Math.round(match.confidence * 100)}%`,
    match.keywords.join('; '),
    match.cpv_codes.join('; '),
    match.tender_url
  ]);

  const csvContent = [
    headers.join(','),
    ...rows.map(row => row.map(cell => `"${cell}"`).join(','))
  ].join('\n');

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `tenderbot-matches-${new Date().toISOString().split('T')[0]}.csv`;
  link.click();
  URL.revokeObjectURL(url);
}
```

### UI Integration

**Export Button Placement:**

1. **Dashboard Feed Tab**
   - Top-right corner: "Export" button with dropdown
   - Options: "Export to Excel", "Export to CSV"
   - Exports current filtered/sorted view

2. **Saved Tenders Tab**
   - Same placement as Feed
   - Exports all saved tenders

3. **Email History Tab**
   - Export delivery log (metadata only, not full HTML)

**Export Modal (Optional):**

```
┌────────────────────────────────┐
│ Export Tender Matches          │
│                                │
│ Format:                        │
│ ○ Excel (.xlsx)                │
│ ● CSV (.csv)                   │
│                                │
│ Include:                       │
│ ☑ Title                        │
│ ☑ Buyer                        │
│ ☑ Region                       │
│ ☑ Value                        │
│ ☑ Deadline                     │
│ ☑ Confidence                   │
│ ☑ Keywords                     │
│ ☑ CPV Codes                    │
│ ☑ URL                          │
│                                │
│ [ Cancel ]  [ Export ]         │
└────────────────────────────────┘
```

**Progress Indicator:**
- For large exports (>100 rows), show progress bar
- "Generating file... (523 / 1000 rows)"

---

## Data Fields to Export

### Tender Matches

| Field | Description | Format |
|-------|-------------|--------|
| Title | Tender title | Text |
| Summary | AI-generated summary | Text (200 chars) |
| Buyer | Contracting authority name | Text |
| Buyer Type | Organization type | Text |
| Region | NUTS region name | Text |
| Value (GBP) | Estimated contract value | Number or "Not disclosed" |
| Deadline | Bid submission deadline | Date (DD/MM/YYYY) |
| Publication Date | When tender was published | Date (DD/MM/YYYY) |
| Confidence | Match confidence score | Percentage (0-100%) |
| Keywords | Matched keywords | Comma-separated |
| CPV Codes | Classification codes | Comma-separated |
| URL | Link to full tender notice | Hyperlink |
| Status | User action (if any) | "Interested" / "Dismissed" / "-" |

### Saved Tenders

Same as Tender Matches + additional field:
- **Saved Date** - When user saved the tender

### Delivery History

| Field | Description | Format |
|-------|-------------|--------|
| Subject | Email subject line | Text |
| Delivered At | Send timestamp | DateTime (DD/MM/YYYY HH:MM) |
| Status | Delivery status | "Sent" / "Failed" / etc. |
| Match Count | Number of tenders in email | Number |
| Alert Profile | Which profile triggered this | Text |

---

## Backend Support (Optional - Phase 2)

### New Endpoint

```http
POST /export/matches
Authorization: Bearer {token}
Content-Type: application/json

{
  "alert_profile_id": "uuid",
  "format": "xlsx" | "csv",
  "date_range": {
    "start": "2024-01-01",
    "end": "2024-01-31"
  },
  "include_fields": ["title", "buyer", "deadline", ...]
}

Response:
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
Content-Disposition: attachment; filename="tenderbot-export-2024-01-31.xlsx"

[Binary file data]
```

**Implementation:**

```python
from openpyxl import Workbook
from fastapi.responses import StreamingResponse
import io

@router.post("/export/matches")
async def export_matches(
    request: ExportRequest,
    current_user: User = Depends(get_current_user)
):
    # Fetch matches
    matches = await matches_repo.get_by_alert_profile(
        request.alert_profile_id,
        start_date=request.date_range.start,
        end_date=request.date_range.end
    )

    # Generate Excel file
    wb = Workbook()
    ws = wb.active
    ws.title = "Tender Matches"

    # Headers
    headers = ["Title", "Buyer", "Deadline", ...]
    ws.append(headers)

    # Data rows
    for match in matches:
        ws.append([match.title, match.buyer_name, match.deadline, ...])

    # Write to buffer
    buffer = io.BytesIO()
    wb.save(buffer)
    buffer.seek(0)

    # Return as streaming response
    return StreamingResponse(
        buffer,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={
            "Content-Disposition": f"attachment; filename=tenderbot-export-{date.today()}.xlsx"
        }
    )
```

---

## Success Metrics

**Adoption:**
- 30%+ of users export at least once per month
- Avg 2-3 exports per active user per month

**Performance:**
- <2 sec to generate file for 100 rows
- <10 sec for 1000 rows
- No browser crashes for exports up to 5000 rows

**User Satisfaction:**
- >90% successful downloads (no errors)
- <5% support tickets related to exports

---

## Future Enhancements

### 1. Scheduled Exports

**Goal:** Automatic weekly/monthly exports via email

**Flow:**
- User configures: "Email me an Excel export every Monday at 9 AM"
- Backend generates file and emails as attachment

### 2. Google Sheets Integration

**Goal:** Live-sync matches to Google Sheets

**Implementation:**
- OAuth with Google Sheets API
- Create spreadsheet on user's Drive
- Append new matches as they arrive
- Two-way sync (mark as interested in Sheets → update in TenderBot)

### 3. Custom Templates

**Goal:** Let users define their own export format

**UI:**
- Drag-and-drop column reordering
- Hide/show fields
- Custom column names
- Save as template for future exports

### 4. Bulk Actions After Export

**Goal:** Import CSV back to mark actions

**Flow:**
- Export to Excel
- Add "Action" column with "interested" / "dismiss"
- Re-upload CSV
- Bulk update tender actions

---

## Dependencies

**Frontend:**
- `exceljs` (npm install exceljs)
- No backend changes for Phase 1

**Backend (Optional - Phase 2):**
- `openpyxl` (Python) or `xlsx` (Node.js)
- File storage (S3) for large exports

---

## Open Questions

1. **File size limits** - What's the max rows we should support? (Recommend 5000)
2. **Storage** - Should we cache generated exports for re-download? (Suggest no - regenerate)
3. **Email attachments** - Should exports be emailable or download-only? (Start download-only)
4. **Privacy** - Should exports include user's email/account info? (Suggest no - just tender data)

---

## References

- ExcelJS Docs: https://github.com/exceljs/exceljs
- CSV RFC 4180: https://tools.ietf.org/html/rfc4180
- Google Sheets API: https://developers.google.com/sheets/api
