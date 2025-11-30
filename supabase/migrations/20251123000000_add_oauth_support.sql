-- Migration: Add OAuth Support (Workspace-Based)
-- Created: November 23, 2025
-- Description: Adds user authentication and OAuth credential storage while preserving workspace architecture

-- ============================================================================
-- PART 1: WORKSPACE-USER MAPPING
-- ============================================================================

-- Link users to workspaces (supports multi-user teams)
CREATE TABLE workspace_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'owner' CHECK (role IN ('owner', 'admin', 'member')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure one user can only have one role per workspace
  UNIQUE(workspace_id, user_id)
);

-- Indexes for performance
CREATE INDEX idx_workspace_users_workspace ON workspace_users(workspace_id);
CREATE INDEX idx_workspace_users_user ON workspace_users(user_id);
CREATE INDEX idx_workspace_users_role ON workspace_users(role);

-- ============================================================================
-- PART 2: OAUTH CONNECTIONS
-- ============================================================================

-- Store OAuth credentials per workspace
CREATE TABLE workspace_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  
  -- Platform identification
  platform TEXT NOT NULL CHECK (platform IN ('shopify', 'klaviyo', 'google_ads', 'meta_ads', 'stripe', 'google_analytics')),
  
  -- OAuth credentials (will be encrypted)
  -- Structure: { access_token, refresh_token, expires_at, scope }
  credentials JSONB NOT NULL,
  
  -- Platform-specific fields
  shop_domain TEXT,      -- For Shopify (e.g., "mystore.myshopify.com")
  account_id TEXT,       -- For other platforms
  account_name TEXT,     -- Display name
  
  -- Connection status
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'expired', 'error', 'disconnected')),
  last_sync_at TIMESTAMP WITH TIME ZONE,
  last_error TEXT,
  
  -- Additional metadata (platform-specific details)
  metadata JSONB DEFAULT '{}'::jsonb,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- One connection per platform per workspace
  UNIQUE(workspace_id, platform)
);

-- Indexes
CREATE INDEX idx_workspace_connections_workspace ON workspace_connections(workspace_id);
CREATE INDEX idx_workspace_connections_platform ON workspace_connections(platform);
CREATE INDEX idx_workspace_connections_status ON workspace_connections(status);
CREATE INDEX idx_workspace_connections_last_sync ON workspace_connections(last_sync_at DESC);

-- ============================================================================
-- PART 3: CONNECTION SYNC LOGS
-- ============================================================================

-- Track sync history for monitoring and debugging
CREATE TABLE connection_sync_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  connection_id UUID REFERENCES workspace_connections(id) ON DELETE CASCADE,
  workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
  
  -- Sync status
  status TEXT CHECK (status IN ('success', 'error', 'partial')) NOT NULL,
  
  -- Metrics
  insights_generated INTEGER DEFAULT 0,
  records_processed INTEGER DEFAULT 0,
  error_message TEXT,
  execution_time_ms INTEGER,
  
  -- Metadata
  metadata JSONB DEFAULT '{}'::jsonb,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_sync_logs_connection ON connection_sync_logs(connection_id);
CREATE INDEX idx_sync_logs_workspace ON connection_sync_logs(workspace_id);
CREATE INDEX idx_sync_logs_status ON connection_sync_logs(status);
CREATE INDEX idx_sync_logs_created ON connection_sync_logs(created_at DESC);

-- ============================================================================
-- PART 4: ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on new tables
ALTER TABLE workspace_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE workspace_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE connection_sync_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PART 5: RLS POLICIES - WORKSPACE_USERS
-- ============================================================================

-- Users can see their own workspace memberships
CREATE POLICY "Users can view own workspace memberships"
  ON workspace_users FOR SELECT
  USING (auth.uid() = user_id);

-- Users can see other members in their workspaces
CREATE POLICY "Users can view workspace members"
  ON workspace_users FOR SELECT
  USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_users WHERE user_id = auth.uid()
    )
  );

-- Only workspace owners can add members
CREATE POLICY "Workspace owners can add members"
  ON workspace_users FOR INSERT
  WITH CHECK (
    workspace_id IN (
      SELECT workspace_id FROM workspace_users 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
  );

-- Only workspace owners can remove members
CREATE POLICY "Workspace owners can remove members"
  ON workspace_users FOR DELETE
  USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_users 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
  );

-- Service role bypass (for n8n and backend operations)
CREATE POLICY "Service role full access to workspace_users"
  ON workspace_users FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- PART 6: RLS POLICIES - WORKSPACE_CONNECTIONS
-- ============================================================================

-- Users can view connections for their workspaces
CREATE POLICY "Users can view workspace connections"
  ON workspace_connections FOR SELECT
  USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_users WHERE user_id = auth.uid()
    )
  );

-- Workspace owners and admins can manage connections
CREATE POLICY "Workspace owners/admins can manage connections"
  ON workspace_connections FOR ALL
  USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_users 
      WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
    )
  );

-- Service role bypass
CREATE POLICY "Service role full access to workspace_connections"
  ON workspace_connections FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- PART 7: RLS POLICIES - CONNECTION_SYNC_LOGS
-- ============================================================================

-- Users can view sync logs for their workspaces
CREATE POLICY "Users can view workspace sync logs"
  ON connection_sync_logs FOR SELECT
  USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_users WHERE user_id = auth.uid()
    )
  );

-- Service role can insert logs
CREATE POLICY "Service role can insert sync logs"
  ON connection_sync_logs FOR INSERT
  TO service_role
  WITH CHECK (true);

-- ============================================================================
-- PART 8: UPDATE EXISTING TABLE RLS POLICIES
-- ============================================================================

-- Update suggestions table policies
DROP POLICY IF EXISTS "Enable all for service role on suggestions" ON suggestions;

CREATE POLICY "Users can view workspace suggestions"
  ON suggestions FOR SELECT
  USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_users WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update workspace suggestions"
  ON suggestions FOR UPDATE
  USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_users WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Service role full access to suggestions"
  ON suggestions FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Update campaign_metrics table policies
DROP POLICY IF EXISTS "Enable all for service role on campaign_metrics" ON campaign_metrics;

CREATE POLICY "Users can view workspace metrics"
  ON campaign_metrics FOR SELECT
  USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_users WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Service role full access to campaign_metrics"
  ON campaign_metrics FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Update job_logs table policies
DROP POLICY IF EXISTS "Enable all for service role on job_logs" ON job_logs;

CREATE POLICY "Users can view workspace job logs"
  ON job_logs FOR SELECT
  USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_users WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Service role full access to job_logs"
  ON job_logs FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Update workspaces table policies
DROP POLICY IF EXISTS "Enable all for service role on workspaces" ON workspaces;

CREATE POLICY "Users can view their workspaces"
  ON workspaces FOR SELECT
  USING (
    id IN (
      SELECT workspace_id FROM workspace_users WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Workspace owners can update their workspaces"
  ON workspaces FOR UPDATE
  USING (
    id IN (
      SELECT workspace_id FROM workspace_users 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
  );

CREATE POLICY "Service role full access to workspaces"
  ON workspaces FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- PART 9: UPDATED_AT TRIGGERS
-- ============================================================================

-- Add updated_at trigger to workspace_users
CREATE TRIGGER update_workspace_users_updated_at
  BEFORE UPDATE ON workspace_users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add updated_at trigger to workspace_connections
CREATE TRIGGER update_workspace_connections_updated_at
  BEFORE UPDATE ON workspace_connections
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- PART 10: HELPER FUNCTIONS
-- ============================================================================

-- Function to get user's default workspace
CREATE OR REPLACE FUNCTION get_user_default_workspace(p_user_id UUID)
RETURNS UUID AS $$
  SELECT workspace_id 
  FROM workspace_users 
  WHERE user_id = p_user_id 
  ORDER BY created_at ASC 
  LIMIT 1;
$$ LANGUAGE SQL STABLE;

-- Function to check if user has access to workspace
CREATE OR REPLACE FUNCTION user_has_workspace_access(p_user_id UUID, p_workspace_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS(
    SELECT 1 
    FROM workspace_users 
    WHERE user_id = p_user_id AND workspace_id = p_workspace_id
  );
$$ LANGUAGE SQL STABLE;

-- Function to check if user is workspace owner
CREATE OR REPLACE FUNCTION user_is_workspace_owner(p_user_id UUID, p_workspace_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS(
    SELECT 1 
    FROM workspace_users 
    WHERE user_id = p_user_id 
      AND workspace_id = p_workspace_id 
      AND role = 'owner'
  );
$$ LANGUAGE SQL STABLE;

-- ============================================================================
-- PART 11: COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE workspace_users IS 'Maps users to workspaces with role-based access control';
COMMENT ON TABLE workspace_connections IS 'Stores OAuth credentials and connection status for each workspace';
COMMENT ON TABLE connection_sync_logs IS 'Tracks sync history and performance metrics for connections';

COMMENT ON COLUMN workspace_connections.credentials IS 'Encrypted JSON containing OAuth tokens: { access_token, refresh_token, expires_at, scope }';
COMMENT ON COLUMN workspace_connections.metadata IS 'Platform-specific details like account info, shop details, etc.';

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

-- Verify tables were created
DO $$
BEGIN
  RAISE NOTICE 'Migration completed successfully!';
  RAISE NOTICE 'Created tables: workspace_users, workspace_connections, connection_sync_logs';
  RAISE NOTICE 'Updated RLS policies for all tables';
  RAISE NOTICE 'Next step: Deploy Supabase Edge Functions for OAuth callbacks';
END $$;