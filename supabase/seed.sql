-- CartPilot v2 Seed Data
-- Run this to populate test data for development

-- Insert test workspace
INSERT INTO workspaces (id, name, shopify_store_url)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'Demo Store', 'demo-store.myshopify.com')
ON CONFLICT (id) DO NOTHING;

-- Insert sample suggestions
INSERT INTO suggestions (
  workspace_id,
  unique_key,
  title,
  summary,
  priority,
  category,
  impact,
  effort,
  what,
  why,
  how,
  data_used,
  actions,
  sources,
  status
) VALUES
(
  '00000000-0000-0000-0000-000000000001',
  'prod-img-001',
  'Improve Product Image Quality',
  'Product images below 1000px width detected',
  'High',
  'product_page',
  'High',
  'Medium',
  'Upload higher resolution product images',
  'Higher quality images increase conversion rates by 20-30%',
  '["Use 2000x2000px minimum", "Ensure white background", "Add lifestyle shots"]'::jsonb,
  '["shopify:products"]'::jsonb,
  '["/admin/products"]'::jsonb,
  '["shopify"]'::jsonb,
  'pending'
),
(
  '00000000-0000-0000-0000-000000000001',
  'email-subject-002',
  'Optimize Email Subject Lines',
  'Low open rates detected on recent campaigns',
  'Medium',
  'email_marketing',
  'Medium',
  'Low',
  'A/B test subject lines with personalization',
  'Personalized subject lines improve open rates by 26%',
  '["Add first name to subject", "Test emoji usage", "Keep under 50 characters"]'::jsonb,
  '["klaviyo:campaigns"]'::jsonb,
  '["/campaigns/edit"]'::jsonb,
  '["klaviyo"]'::jsonb,
  'pending'
),
(
  '00000000-0000-0000-0000-000000000001',
  'inventory-003',
  'Low Stock Alert: Blue T-Shirt',
  'Popular item running low on inventory',
  'Critical',
  'inventory',
  'High',
  'Low',
  'Reorder 100 units immediately',
  'Item has sold 50 units in last 7 days, only 15 remaining',
  '["Contact supplier", "Place emergency order", "Enable low stock notification"]'::jsonb,
  '["shopify:inventory"]'::jsonb,
  '["/admin/reorder?sku=BLUE-TSHIRT"]'::jsonb,
  '["shopify"]'::jsonb,
  'pending'
);

-- Insert sample campaign metrics
INSERT INTO campaign_metrics (
  workspace_id,
  source,
  metric,
  ts,
  value,
  campaign_id,
  campaign_name
) VALUES
(
  '00000000-0000-0000-0000-000000000001',
  'klaviyo',
  'email_sent',
  NOW() - INTERVAL '1 day',
  5000,
  'welcome-series-001',
  'Welcome Series'
),
(
  '00000000-0000-0000-0000-000000000001',
  'klaviyo',
  'email_opened',
  NOW() - INTERVAL '1 day',
  1250,
  'welcome-series-001',
  'Welcome Series'
),
(
  '00000000-0000-0000-0000-000000000001',
  'shopify',
  'revenue',
  NOW() - INTERVAL '1 day',
  15000.00,
  NULL,
  'Daily Revenue'
),
(
  '00000000-0000-0000-0000-000000000001',
  'shopify',
  'orders',
  NOW() - INTERVAL '1 day',
  87,
  NULL,
  'Daily Orders'
);

-- Insert sample job logs
INSERT INTO job_logs (
  workspace_id,
  job_id,
  job_type,
  status,
  message
) VALUES
(
  '00000000-0000-0000-0000-000000000001',
  'sync-shopify-001',
  'shopify_sync',
  'completed',
  'Successfully synced 150 products'
),
(
  '00000000-0000-0000-0000-000000000001',
  'sync-klaviyo-001',
  'klaviyo_sync',
  'completed',
  'Successfully synced 3 campaigns'
);