-- CartPilot v2 Initial Schema
-- This creates all tables needed for the MVP

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Workspaces table (for multi-tenant support)
CREATE TABLE workspaces (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  shopify_store_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Suggestions table (AI-generated recommendations)
CREATE TABLE suggestions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  unique_key TEXT NOT NULL,
  
  -- Suggestion content
  title TEXT NOT NULL,
  summary TEXT,
  priority TEXT CHECK (priority IN ('Low', 'Medium', 'High', 'Critical')),
  category TEXT NOT NULL,
  
  -- Impact & effort
  impact TEXT CHECK (impact IN ('Low', 'Medium', 'High')),
  effort TEXT CHECK (effort IN ('Low', 'Medium', 'High')),
  
  -- Details
  what TEXT,
  why TEXT,
  how JSONB DEFAULT '[]'::jsonb,
  data_used JSONB DEFAULT '[]'::jsonb,
  
  -- Actions & metadata
  actions JSONB DEFAULT '[]'::jsonb,
  sources JSONB DEFAULT '[]'::jsonb,
  meta JSONB DEFAULT '{}'::jsonb,
  
  -- Status tracking
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'snoozed', 'resolved')),
  status_changed_at TIMESTAMP WITH TIME ZONE,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure uniqueness per workspace
  UNIQUE(workspace_id, unique_key)
);

-- Campaign metrics table (from Klaviyo, Shopify, etc.)
CREATE TABLE campaign_metrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  
  -- Metric identification
  source TEXT NOT NULL, -- 'klaviyo', 'shopify', etc.
  metric TEXT NOT NULL, -- 'email_sent', 'conversion_rate', etc.
  ts TIMESTAMP WITH TIME ZONE NOT NULL,
  
  -- Metric data
  value NUMERIC NOT NULL,
  campaign_id TEXT,
  campaign_name TEXT,
  meta JSONB DEFAULT '{}'::jsonb,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure uniqueness per metric per time
  UNIQUE(workspace_id, source, ts, metric)
);

-- Job logs table (workflow execution tracking)
CREATE TABLE job_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  
  -- Job identification
  job_id TEXT NOT NULL,
  job_type TEXT NOT NULL,
  
  -- Status tracking
  status TEXT DEFAULT 'acknowledged' CHECK (status IN ('acknowledged', 'running', 'completed', 'failed')),
  message TEXT,
  meta JSONB DEFAULT '{}'::jsonb,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_suggestions_workspace ON suggestions(workspace_id);
CREATE INDEX idx_suggestions_status ON suggestions(status);
CREATE INDEX idx_suggestions_created ON suggestions(created_at DESC);
CREATE INDEX idx_campaign_metrics_workspace ON campaign_metrics(workspace_id);
CREATE INDEX idx_campaign_metrics_ts ON campaign_metrics(ts DESC);
CREATE INDEX idx_job_logs_workspace ON job_logs(workspace_id);
CREATE INDEX idx_job_logs_created ON job_logs(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE suggestions ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies (allow service role full access for now)
-- You can add user-based policies later when you add authentication

CREATE POLICY "Enable all for service role on workspaces"
  ON workspaces FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Enable all for service role on suggestions"
  ON suggestions FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Enable all for service role on campaign_metrics"
  ON campaign_metrics FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Enable all for service role on job_logs"
  ON job_logs FOR ALL
  USING (true)
  WITH CHECK (true);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers
CREATE TRIGGER update_workspaces_updated_at
  BEFORE UPDATE ON workspaces
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_suggestions_updated_at
  BEFORE UPDATE ON suggestions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_campaign_metrics_updated_at
  BEFORE UPDATE ON campaign_metrics
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_job_logs_updated_at
  BEFORE UPDATE ON job_logs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();