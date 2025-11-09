# CartPilot v2 - Quick Reference Card

Keep this handy for daily development!

## 🔑 Essential URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Supabase Dashboard | https://app.supabase.com | Manage database, view tables |
| N8N Cloud | https://app.n8n.cloud | Build workflows |
| Loveable | https://lovable.dev | Frontend builder |
| GitHub Repo | https://github.com/YOUR_USERNAME/cartpilot-v2 | Code repository |
| Supabase API Docs | https://supabase.com/docs | API reference |
| N8N Docs | https://docs.n8n.io | Workflow help |

## 🚀 Common Commands

### Local Development
```bash
# Start Supabase locally (optional)
supabase start

# Push database changes
supabase db push

# Pull database schema
supabase db pull

# Create new migration
supabase migration new your_migration_name

# Reset database (WARNING: deletes data)
supabase db reset

# Seed test data
supabase db seed
```

### Git Workflow
```bash
# Save your work
git add .
git commit -m "Description of changes"
git push origin main

# Check status
git status

# View changes
git diff
```

## 🔐 Where to Find Keys

### Supabase Keys
**Location:** Supabase Dashboard → Settings → API

- **Project URL**: Use in API calls
- **anon public**: Frontend, N8N (safe to expose)
- **service_role**: N8N only (keep secret!)

### N8N Environment Variables
**Location:** N8N Dashboard → Settings → Variables

Set these:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY` 
- `DEFAULT_WORKSPACE_ID`
- `OPENAI_API_KEY`

### Loveable Environment Variables
**Location:** Loveable Project Settings → Environment

Set these:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`
- `VITE_DEFAULT_WORKSPACE_ID`

## 📊 Key Database Tables

### suggestions
**Purpose:** AI-generated recommendations
**Key Fields:**
- `workspace_id` - Which store
- `unique_key` - Deduplication
- `status` - pending/accepted/rejected/snoozed
- `title`, `category`, `priority`

### campaign_metrics
**Purpose:** Performance data from Klaviyo/Shopify
**Key Fields:**
- `source` - klaviyo/shopify
- `metric` - email_sent/revenue/orders
- `ts` - Timestamp
- `value` - Numeric value

### job_logs
**Purpose:** Track N8N workflow executions
**Key Fields:**
- `job_id` - Unique identifier
- `status` - acknowledged/running/completed/failed
- `message` - What happened

## 🔌 API Quick Examples

### Create Suggestion (curl)
```bash
curl -X POST "$SUPABASE_URL/rest/v1/suggestions" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "workspace_id": "UUID",
    "unique_key": "test-001",
    "title": "Test",
    "category": "product_page",
    "status": "pending"
  }'
```

### Get Suggestions (JavaScript)
```javascript
const { data } = await supabase
  .from('suggestions')
  .select('*')
  .eq('workspace_id', workspaceId)
  .eq('status', 'pending')
```

### Update Status (JavaScript)
```javascript
const { data } = await supabase
  .from('suggestions')
  .update({ status: 'accepted' })
  .eq('id', suggestionId)
```

## 🎯 N8N Workflow Template

**Basic Structure:**
1. **Trigger** (Webhook/Schedule/Manual)
2. **Get Data** (Shopify/Klaviyo API)
3. **Process with AI** (ChatGPT node)
4. **Save to Supabase** (HTTP Request)
5. **Log Result** (HTTP Request to job_logs)

**Required Headers for Supabase:**
```
apikey: {{ $env.SUPABASE_ANON_KEY }}
Authorization: Bearer {{ $env.SUPABASE_ANON_KEY }}
Content-Type: application/json
```

## 🐛 Debugging Checklist

### N8N Workflow Not Working?
- [ ] Check execution log for errors
- [ ] Verify environment variables are set
- [ ] Test Supabase URL with curl
- [ ] Check credentials haven't expired

### Frontend Can't Connect?
- [ ] Verify VITE_* env vars are set
- [ ] Check browser console for errors
- [ ] Test Supabase API directly with curl
- [ ] Ensure workspace_id is correct

### No Data in Supabase?
- [ ] Check Table Editor in Supabase dashboard
- [ ] Verify N8N workflow executed successfully
- [ ] Check API response in N8N logs
- [ ] Ensure workspace_id matches

### Suggestions Not Appearing?
- [ ] Verify workspace_id in query
- [ ] Check RLS policies (should be permissive for MVP)
- [ ] Test query directly in Supabase SQL editor
- [ ] Check frontend is using correct Supabase URL

## 📞 Getting Help

1. **Check Documentation**
   - `/docs/setup.md` - Setup instructions
   - `/docs/api-reference.md` - API details
   - `IMPLEMENTATION_CHECKLIST.md` - Track progress

2. **Test Systematically**
   - Start with curl (eliminates frontend issues)
   - Test N8N workflows in isolation
   - Check Supabase Table Editor

3. **Common Issues**
   - Wrong workspace_id
   - Expired/incorrect API keys
   - Missing environment variables
   - CORS errors (shouldn't happen with Supabase)

## 💡 Pro Tips

- **Always test API with curl first** before building workflows
- **Export N8N workflows weekly** to `/n8n-workflows/` for backup
- **Use Supabase Table Editor** to verify data quickly
- **Check N8N execution logs** when workflows fail
- **Use unique_key** in suggestions to prevent duplicates
- **Start simple** - get one workflow working perfectly before adding complexity

## 🎨 Workflow Ideas

1. **Low Stock Alert**: Shopify inventory → ChatGPT → Suggestion
2. **Email Performance**: Klaviyo metrics → ChatGPT → Suggestion
3. **Product Optimization**: Shopify product data → ChatGPT → Suggestion
4. **Revenue Drops**: Shopify orders → Detect pattern → Alert
5. **Campaign Review**: Klaviyo campaign → Analyze → Recommendations

## 📈 Success Metrics

Track these to know you're on the right path:

- [ ] Suggestions appearing in Loveable
- [ ] Can Accept/Reject suggestions
- [ ] Status updates saving to Supabase
- [ ] N8N workflows executing reliably
- [ ] ChatGPT generating relevant suggestions
- [ ] Data flowing from Shopify/Klaviyo

## 🔄 Daily Workflow

**Start of Day:**
1. Pull latest code: `git pull`
2. Check N8N execution history
3. Review Supabase Table Editor

**During Development:**
1. Make changes
2. Test immediately
3. Commit often: `git commit -m "..."`

**End of Day:**
1. Push code: `git push`
2. Export N8N workflows
3. Update checklist
4. Document any issues

---

**Remember:** You're building an MVP. Simple and working beats complex and broken!