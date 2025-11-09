# CartPilot API Reference

Supabase auto-generates a REST API for all your tables. Here's how to use it.

## Base URL
```
https://YOUR_PROJECT.supabase.co/rest/v1
```

## Authentication

All requests require these headers:
```bash
apikey: YOUR_ANON_KEY
Authorization: Bearer YOUR_ANON_KEY
Content-Type: application/json
```

For write operations from N8N, use `service_role` key instead.

## Suggestions API

### Get All Suggestions
```bash
GET /suggestions?workspace_id=eq.YOUR_WORKSPACE_ID
```

**Response:**
```json
[
  {
    "id": "uuid",
    "workspace_id": "uuid",
    "unique_key": "prod-img-001",
    "title": "Improve Product Images",
    "summary": "...",
    "priority": "High",
    "category": "product_page",
    "impact": "High",
    "effort": "Medium",
    "status": "pending",
    "created_at": "2025-11-09T10:00:00Z"
  }
]
```

### Get Single Suggestion
```bash
GET /suggestions?id=eq.SUGGESTION_UUID
```

### Filter by Status
```bash
GET /suggestions?workspace_id=eq.YOUR_WORKSPACE_ID&status=eq.pending
```

### Filter by Category
```bash
GET /suggestions?workspace_id=eq.YOUR_WORKSPACE_ID&category=eq.product_page
```

### Create Suggestion
```bash
POST /suggestions
```

**Body:**
```json
{
  "workspace_id": "uuid",
  "unique_key": "unique-identifier",
  "title": "Suggestion Title",
  "summary": "Brief description",
  "priority": "High",
  "category": "product_page",
  "impact": "High",
  "effort": "Low",
  "what": "What to do",
  "why": "Why it matters",
  "how": ["Step 1", "Step 2"],
  "data_used": ["source:data"],
  "actions": ["/admin/link"],
  "sources": ["shopify"],
  "status": "pending"
}
```

**Upsert (Insert or Update):**
Add header: `Prefer: resolution=merge-duplicates`

This will update if `(workspace_id, unique_key)` already exists.

### Update Suggestion
```bash
PATCH /suggestions?id=eq.SUGGESTION_UUID
```

**Body:**
```json
{
  "status": "accepted",
  "status_changed_at": "2025-11-09T10:00:00Z"
}
```

### Delete Suggestion
```bash
DELETE /suggestions?id=eq.SUGGESTION_UUID
```

## Campaign Metrics API

### Get Metrics
```bash
GET /campaign_metrics?workspace_id=eq.YOUR_WORKSPACE_ID
```

### Filter by Source
```bash
GET /campaign_metrics?workspace_id=eq.YOUR_WORKSPACE_ID&source=eq.klaviyo
```

### Filter by Date Range
```bash
GET /campaign_metrics?workspace_id=eq.YOUR_WORKSPACE_ID&ts=gte.2025-11-01&ts=lte.2025-11-09
```

### Create Metric
```bash
POST /campaign_metrics
```

**Body:**
```json
{
  "workspace_id": "uuid",
  "source": "klaviyo",
  "metric": "email_sent",
  "ts": "2025-11-09T10:00:00Z",
  "value": 5000,
  "campaign_id": "camp-001",
  "campaign_name": "Welcome Series"
}
```

**Upsert:**
Add header: `Prefer: resolution=merge-duplicates`

## Job Logs API

### Get Job Logs
```bash
GET /job_logs?workspace_id=eq.YOUR_WORKSPACE_ID&order=created_at.desc
```

### Create Job Log
```bash
POST /job_logs
```

**Body:**
```json
{
  "workspace_id": "uuid",
  "job_id": "unique-job-id",
  "job_type": "shopify_sync",
  "status": "acknowledged",
  "message": "Starting sync..."
}
```

### Update Job Status
```bash
PATCH /job_logs?job_id=eq.UNIQUE_JOB_ID
```

**Body:**
```json
{
  "status": "completed",
  "message": "Sync completed successfully"
}
```

## Workspaces API

### Get Workspaces
```bash
GET /workspaces
```

### Create Workspace
```bash
POST /workspaces
```

**Body:**
```json
{
  "name": "My Store",
  "shopify_store_url": "mystore.myshopify.com"
}
```

## Advanced Queries

### Sorting
```bash
# Descending order
GET /suggestions?order=created_at.desc

# Multiple sorts
GET /suggestions?order=priority.desc,created_at.desc
```

### Pagination
```bash
# Limit results
GET /suggestions?limit=10

# Offset (skip first 10)
GET /suggestions?limit=10&offset=10
```

### Count
```bash
# Get count only
GET /suggestions?workspace_id=eq.YOUR_ID&select=count

# Count with data
GET /suggestions?workspace_id=eq.YOUR_ID&select=*,count
```

### Select Specific Fields
```bash
GET /suggestions?select=id,title,status,created_at
```

### Complex Filters
```bash
# OR condition
GET /suggestions?or=(status.eq.pending,status.eq.accepted)

# NOT condition
GET /suggestions?status=not.eq.rejected

# IN condition
GET /suggestions?priority=in.(High,Critical)
```

## Response Preferences

### Return Created/Updated Record

Add header:
```
Prefer: return=representation
```

This returns the created/updated record in the response.

### Upsert on Conflict

Add header:
```
Prefer: resolution=merge-duplicates
```

This updates existing records instead of throwing an error.

## Error Responses

### 400 Bad Request
```json
{
  "code": "PGRST102",
  "message": "Invalid query parameter",
  "details": "..."
}
```

### 401 Unauthorized
```json
{
  "message": "Invalid API key"
}
```

### 409 Conflict
```json
{
  "code": "23505",
  "message": "duplicate key value violates unique constraint"
}
```

## Rate Limits

Free tier:
- 500 requests per second
- 2GB database
- Unlimited API requests

## Examples from JavaScript

### Using Supabase Client
```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://YOUR_PROJECT.supabase.co',
  'YOUR_ANON_KEY'
)

// Get suggestions
const { data, error } = await supabase
  .from('suggestions')
  .select('*')
  .eq('workspace_id', workspaceId)
  .eq('status', 'pending')

// Create suggestion
const { data, error } = await supabase
  .from('suggestions')
  .insert({
    workspace_id: workspaceId,
    unique_key: 'test-001',
    title: 'Test Suggestion',
    category: 'test'
  })

// Update suggestion
const { data, error } = await supabase
  .from('suggestions')
  .update({ status: 'accepted' })
  .eq('id', suggestionId)

// Upsert (insert or update)
const { data, error } = await supabase
  .from('suggestions')
  .upsert({
    workspace_id: workspaceId,
    unique_key: 'test-001',
    title: 'Updated Title'
  })
```

### Using Fetch (N8N)
```javascript
const response = await fetch(
  `${process.env.SUPABASE_URL}/rest/v1/suggestions`,
  {
    method: 'POST',
    headers: {
      'apikey': process.env.SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${process.env.SUPABASE_ANON_KEY}`,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation'
    },
    body: JSON.stringify({
      workspace_id: workspaceId,
      unique_key: 'test-001',
      title: 'Test'
    })
  }
)

const data = await response.json()
```

## Further Reading

- [PostgREST API Documentation](https://postgrest.org/en/stable/api.html)
- [Supabase JavaScript Client Docs](https://supabase.com/docs/reference/javascript)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)