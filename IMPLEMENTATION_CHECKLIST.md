# CartPilot v2 Implementation Checklist

Use this to track your progress through the setup.

## ✅ Phase 1: GitHub Setup (Day 1 - Morning)

- [ ] Create GitHub repository `cartpilot-v2`
- [ ] Clone repository locally
- [ ] Create folder structure
- [ ] Copy all artifact files into repository
- [ ] Run `npm install`
- [ ] Commit and push to GitHub
- [ ] Repository URL: ________________

**Estimated time:** 15 minutes

---

## ✅ Phase 2: Supabase Setup (Day 1 - Afternoon)

- [ ] Create Supabase account
- [ ] Create new project "cartpilot"
- [ ] Save database password: ________________
- [ ] Copy Project URL: ________________
- [ ] Copy anon key: ________________
- [ ] Copy service_role key: ________________
- [ ] Create `.env` file with keys
- [ ] Install Supabase CLI: `npm install -g supabase`
- [ ] Login to Supabase CLI: `supabase login`
- [ ] Link project: `supabase link --project-ref XXXXX`
- [ ] Push database schema: `supabase db push`
- [ ] Verify tables in Table Editor
- [ ] Create test workspace in Supabase dashboard
- [ ] Copy workspace UUID: ________________
- [ ] Add workspace UUID to `.env`
- [ ] Test API with curl (see setup.md)
- [ ] API test successful: ☐ Yes ☐ No

**Estimated time:** 30 minutes

---

## ✅ Phase 3: N8N Cloud Setup (Day 1 - Evening)

- [ ] Create N8N Cloud account
- [ ] Verify email
- [ ] Login to app.n8n.cloud
- [ ] Create "Test - Supabase Connection" workflow
- [ ] Add Supabase credential
- [ ] Add environment variables in N8N:
  - [ ] SUPABASE_URL
  - [ ] SUPABASE_ANON_KEY
  - [ ] DEFAULT_WORKSPACE_ID
- [ ] Create and test simple workflow
- [ ] Workflow executes successfully: ☐ Yes ☐ No
- [ ] Check Supabase Table Editor - test data appears: ☐ Yes ☐ No

**Estimated time:** 30 minutes

---

## ✅ Phase 4: Loveable Integration (Day 2)

- [ ] Add Supabase environment variables to Loveable:
  - [ ] VITE_SUPABASE_URL
  - [ ] VITE_SUPABASE_ANON_KEY
  - [ ] VITE_DEFAULT_WORKSPACE_ID
- [ ] Install Supabase client: `npm install @supabase/supabase-js`
- [ ] Copy `supabase-client.js` helper to Loveable project
- [ ] Test getSuggestions() function
- [ ] Test updateSuggestionStatus() function
- [ ] Frontend can read from Supabase: ☐ Yes ☐ No
- [ ] Frontend can write to Supabase: ☐ Yes ☐ No

**Estimated time:** 1 hour

---

## ✅ Phase 5: First Real Workflow (Day 3)

**Goal:** Shopify low stock → ChatGPT → Supabase

- [ ] Get OpenAI API key: ________________
- [ ] Add to N8N environment variables
- [ ] Create workflow "Low Stock Alert"
- [ ] Add Shopify webhook trigger (or manual trigger for testing)
- [ ] Add ChatGPT node to generate suggestion
- [ ] Add HTTP Request to Supabase to insert suggestion
- [ ] Test with manual trigger
- [ ] Workflow creates suggestion in Supabase: ☐ Yes ☐ No
- [ ] Suggestion visible in Loveable frontend: ☐ Yes ☐ No

**Estimated time:** 2 hours

---

## ✅ Phase 6: Shopify Integration (Day 4)

- [ ] Create Shopify Partner account
- [ ] Create development store (if needed)
- [ ] Create custom app in Shopify
- [ ] Get Shopify credentials:
  - [ ] API key: ________________
  - [ ] API secret: ________________
  - [ ] Access token: ________________
- [ ] Add to N8N credentials
- [ ] Set up Shopify webhook in N8N
- [ ] Test: Update product in Shopify → N8N receives webhook
- [ ] Webhook working: ☐ Yes ☐ No

**Estimated time:** 2 hours

---

## ✅ Phase 7: Klaviyo Integration (Day 5)

- [ ] Get Klaviyo account (or use existing)
- [ ] Generate Klaviyo private API key: ________________
- [ ] Add to N8N credentials
- [ ] Create workflow "Klaviyo Campaign Metrics"
- [ ] Fetch campaign data from Klaviyo
- [ ] Store metrics in Supabase campaign_metrics table
- [ ] Test workflow
- [ ] Metrics appear in Supabase: ☐ Yes ☐ No

**Estimated time:** 2 hours

---

## ✅ Phase 8: Full E2E Test (Day 6)

**Test Scenario:** Shopify inventory change → ChatGPT suggestion → Loveable display → Accept → Push back to Shopify

- [ ] Trigger: Change inventory in Shopify
- [ ] Verify: N8N webhook receives event
- [ ] Verify: ChatGPT generates suggestion
- [ ] Verify: Suggestion saved to Supabase
- [ ] Verify: Suggestion appears in Loveable UI
- [ ] Action: Click "Accept" in Loveable
- [ ] Verify: Status updated in Supabase
- [ ] Verify: N8N workflow triggered to push to Shopify
- [ ] Verify: Change applied in Shopify
- [ ] Full flow working: ☐ Yes ☐ No

**Estimated time:** 3 hours

---

## 🎯 MVP Complete Checklist

- [ ] Users can see suggestions in Loveable
- [ ] Users can Accept/Reject/Snooze suggestions
- [ ] Shopify data flows to suggestions
- [ ] Klaviyo data flows to metrics
- [ ] ChatGPT generates relevant suggestions
- [ ] Accepted suggestions push back to Shopify/Klaviyo
- [ ] Basic error handling in place
- [ ] Documentation up to date

**Target:** 1 week from start

---

## 🚀 Post-MVP Enhancements

- [ ] Add user authentication (Supabase Auth)
- [ ] Multi-workspace support
- [ ] Dashboard with metrics visualization
- [ ] Email notifications for critical suggestions
- [ ] Shopify app listing
- [ ] Payment integration
- [ ] Customer beta testing

---

## 📊 Weekly Progress Tracking

### Week 1 Goal: Working MVP
- Day 1: Setup complete ☐
- Day 2: Loveable connected ☐
- Day 3: First workflow working ☐
- Day 4: Shopify integrated ☐
- Day 5: Klaviyo integrated ☐
- Day 6: E2E test passing ☐
- Day 7: Buffer/documentation ☐

### Week 2 Goal: Polish & Test
- Refinements
- User testing
- Bug fixes
- Documentation

---

## ❓ Stuck? Debug Checklist

If something isn't working:

1. [ ] Check `.env` file has all required values
2. [ ] Verify keys haven't expired
3. [ ] Check Supabase Table Editor for data
4. [ ] Check N8N execution logs for errors
5. [ ] Test API with curl commands from docs
6. [ ] Review setup.md troubleshooting section
7. [ ] Check browser console for frontend errors
8. [ ] Verify workspace_id matches across all systems

---

## 💾 Backup Strategy

- [ ] GitHub: Push code daily
- [ ] N8N: Export workflows weekly → save to `/n8n-workflows/`
- [ ] Supabase: Automatic daily backups (included)
- [ ] Document credentials in password manager

---

## 📝 Notes & Observations
