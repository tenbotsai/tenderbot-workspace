# Data Ingestion System

**Status:** ✅ COMPLETE (Find a Tender) | 📋 PLANNED (Contracts Finder)

**Last Updated:** 2026-02-07

---

## Overview

The data ingestion system automatically fetches tender opportunities from UK public sector procurement platforms, normalizes the data into a consistent format, and stores it for matching against user alert profiles.

### Current State

**Find a Tender (COMPLETE)**
- Hourly incremental ingestion via Prefect workflow
- OCDS (Open Contracting Data Standard) Release Package format
- Automatic pagination and cursor-based resume
- Rate limiting and retry handling
- 12-month historical backfill capability

**Contracts Finder (PLANNED)**
- Not yet implemented
- Will provide additional coverage for lower-value contracts
- Similar OCDS format expected

---

## User Value

- **SMEs get comprehensive coverage** - Access to all UK public sector opportunities in one place
- **Real-time updates** - New tenders available within 1 hour of publication
- **Historical data** - Access to 12 months of past opportunities for market research

---

## Technical Design

### Architecture

```
Find a Tender API → Prefect Flow → Parser → Database
                                      ↓
                              Deduplication
                                      ↓
                              Normalization
```

### Data Model

**Database Table: `tenders`**

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| source | TEXT | "find-tender" or "contracts-finder" |
| ocid | TEXT | OCDS identifier (unique per source) |
| release_id | TEXT | Release version identifier |
| title | TEXT | Tender title |
| description | TEXT | Full tender description |
| cpv_codes | JSONB | Array of CPV classification codes |
| nuts_codes | JSONB | Array of regional NUTS codes |
| buyer_name | TEXT | Contracting authority name |
| buyer_type | TEXT | Organization type (e.g., "local-authority") |
| buyer_id | TEXT | Unique buyer identifier |
| bid_deadline | TIMESTAMP | Submission deadline (UTC) |
| publication_date | TIMESTAMP | Original publication date |
| updated_at_source | TIMESTAMP | Last modified at source |
| value_min_gbp | DECIMAL | Minimum contract value (GBP) |
| value_max_gbp | DECIMAL | Maximum contract value (GBP) |
| currency | TEXT | Original currency code |
| tender_url | TEXT | Link to full tender notice |
| created_at | TIMESTAMP | Ingestion timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

**Indexes:**
- GIN index on `cpv_codes` for fast array overlap queries
- Unique constraint on `(source, ocid)` for deduplication
- B-tree on `publication_date`, `bid_deadline` for filtering

### Find a Tender API Integration

**Endpoint:** `https://www.find-tender.service.gov.uk/api/1.0/ocdsReleasePackages`

**Query Parameters:**
- `updatedFrom` - ISO timestamp (window start)
- `updatedTo` - ISO timestamp (window end)
- `stages=tender` - Filter for tender stage only
- `cursor` - Pagination token

**Response Format:** OCDS Release Package
```json
{
  "releases": [
    {
      "ocid": "ocds-b5fd17-abc123",
      "id": "ocds-b5fd17-abc123-2024-01-15T10:00:00Z",
      "date": "2024-01-15T10:00:00Z",
      "tender": {
        "id": "...",
        "title": "Provision of IT Services",
        "description": "...",
        "items": [
          {
            "classification": {
              "scheme": "CPV",
              "id": "72000000",
              "description": "IT services"
            }
          }
        ],
        "tenderPeriod": {
          "endDate": "2024-02-15T17:00:00Z"
        },
        "value": {
          "amount": 100000,
          "currency": "GBP"
        }
      },
      "parties": [
        {
          "id": "GB-LAC-12345",
          "name": "Example Council",
          "roles": ["buyer"]
        }
      ]
    }
  ],
  "links": {
    "next": "https://...?cursor=xyz"
  }
}
```

### Ingestion Workflow (Prefect)

**Flow:** `ingest_tenders_flow`

**Schedule:** Every 15 minutes (configurable)

**Steps:**

1. **Check Ingestion State**
   - Query `ingestion_state` table for last cursor
   - Calculate window: `[last_window_end, now - 2min buffer]`
   - Default window size: 15 minutes

2. **Fetch from API**
   - Call Find a Tender API with window parameters
   - Handle pagination via `cursor` in response
   - Retry on 429/503/504 with exponential backoff

3. **Parse Releases**
   - Extract fields from OCDS structure
   - Normalize CPV codes (strip descriptions, keep IDs)
   - Parse NUTS codes from location fields
   - Convert dates to UTC timestamps
   - Extract buyer info from `parties` array

4. **Deduplicate & Upsert**
   - Use `ON CONFLICT (source, ocid) DO UPDATE`
   - Update existing records if `updated_at_source` is newer
   - Track counts: new, updated, skipped, invalid

5. **Update State**
   - Save final cursor to `ingestion_state`
   - Log summary metrics
   - Alert on errors

**Error Handling:**
- Rate limit errors → exponential backoff (max 5 retries)
- Parse errors → log invalid release, continue
- API timeout → retry with longer timeout
- Network errors → retry flow on next schedule

### File Locations

**Backend Implementation:**
- Flow: `/backend/tenderbot/tasks/flows/ingest_tenders_flow.py`
- Task: `/backend/tenderbot/tasks/ingest_tenders_task.py`
- Client: `/backend/tenderbot/services/find_tender_ocds_client.py`
- Parser: `/backend/tenderbot/services/ocds_parser.py`
- Repository: `/backend/tenderbot/data/tenders_repo.py`

---

## Contracts Finder Integration

### Status: PLANNED

**API:** `https://www.contractsfinder.service.gov.uk/`

**Differences from Find a Tender:**
- Covers contracts £12,000 - £139,688 (below OJEU threshold)
- Different OCDS schema (may need adapter)
- Less structured data (more parsing required)
- No guaranteed OCDS format

**Implementation Plan:**

1. **Research Phase** (1 week)
   - API documentation review
   - Sample data analysis
   - Schema mapping to existing data model

2. **Client Development** (1 week)
   - Create `ContractsFinderClient` class
   - Implement pagination and retry logic
   - Write parser for Contracts Finder OCDS variant

3. **Integration** (1 week)
   - Add to existing ingestion flow
   - Update `source` field to distinguish datasets
   - Test deduplication across sources
   - Backfill historical data (12 months)

4. **Validation** (3 days)
   - Verify data quality
   - Check for duplicates with Find a Tender
   - User acceptance testing

**Success Metrics:**
- 95%+ successful ingestion rate
- <5% duplicate rate across sources
- <10min delay from publication to availability

---

## Normalization

### CPV Codes

**Input Formats:**
- Full CPV: "72000000 - IT services: consulting, software development"
- Short CPV: "72000000"
- Invalid/missing CPV: null or empty string

**Normalization:**
- Extract 8-digit code only: `72000000`
- Store as JSONB array: `["72000000", "72200000"]`
- Strip all descriptions and punctuation
- Deduplicate within tender

### NUTS Codes

**Input Formats:**
- `tender.deliveryLocation.region.uri`: "http://data.europa.eu/nuts/code/UKI"
- `parties[].address.region`: "London"

**Normalization:**
- Extract NUTS code from URI: `UKI`
- Map UK regions to NUTS codes via lookup table
- Store as JSONB array: `["UKI", "UKJ"]`

### Dates & Times

**Rules:**
- All timestamps stored in UTC
- Parse ISO 8601 formats
- Handle missing timezones (assume UTC)
- Set `bid_deadline` to end of day if time not specified

### Values & Currency

**Conversion:**
- Extract from `tender.value.amount` and `tender.value.currency`
- Convert to GBP using daily exchange rates (if non-GBP)
- Handle ranges: `tender.minValue` and `tender.maxValue`
- Store null if value not disclosed

---

## Success Metrics

**Operational:**
- 99.5% uptime for ingestion pipeline
- <1 hour latency from publication to availability
- <0.1% parse error rate

**Data Quality:**
- 100% of tenders have valid OCID
- >95% have CPV codes
- >90% have bid deadline
- >80% have value estimate

**Coverage:**
- Ingest 100% of Find a Tender releases
- Maintain 12-month rolling history
- Zero data loss during outages (resume from cursor)

---

## Future Enhancements

### Scotland Public Contracts
- Separate platform: `publiccontractsscotland.gov.uk`
- May require custom scraper (no standard API)
- Estimated +15% additional opportunities

### TED (Tenders Electronic Daily)
- EU-wide tender database
- OCDS-compliant API available
- Useful for UK companies bidding internationally
- Large volume (~2000 tenders/day across EU)

### Duplicate Detection
- Cross-source deduplication (same tender on multiple platforms)
- Fuzzy matching on title + buyer + deadline
- ML-based similarity scoring

### Data Enrichment
- Buyer organization profiles (size, sector, past awards)
- Competitor intelligence (who else is bidding)
- Historical win rates by CPV code

---

## Dependencies

**Technical:**
- Prefect 2.x for workflow orchestration
- PostgreSQL 15+ with JSONB support
- `httpx` for async API calls
- `pydantic` for validation

**External:**
- Find a Tender API availability
- Stable OCDS schema (breaking changes rare)
- Rate limits: 100 requests/min (current)

---

## Open Questions

1. **Contracts Finder API stability** - Is it reliable enough for production use?
2. **Historical backfill scope** - Should we ingest more than 12 months?
3. **Data retention policy** - Archive old tenders after how long?
4. **Change detection** - Should we track tender amendments/cancellations?

---

## References

- Find a Tender API Docs: https://www.find-tender.service.gov.uk/api-documentation
- OCDS Standard: https://standard.open-contracting.org/
- CPV Code List: https://simap.ted.europa.eu/web/simap/cpv
- NUTS Regions: https://ec.europa.eu/eurostat/web/nuts
