/*
  # TPF System - Update Projects and System Settings
  
  ## Overview
  Updates the existing projects table to add TPF ID field and creates system settings for POD numbering.
  
  ## 1. Table Updates
  
  ### `projects` table additions
  - `tpf_id` (text, unique) - Official project number (e.g., POD-1024)
  
  ### `app_settings` table
  - Uses existing table to store next_pod_number
  
  ## 2. Security
  - Update RLS policies for projects to ensure proper access control
  - Only Admins can create/update/delete projects
  - All authenticated users can read projects
  
  ## 3. Important Notes
  - Integrates with existing projects table structure
  - Uses app_settings table for configuration
  - Default next_pod_number set to 1000
*/

-- Add tpf_id column to projects if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'tpf_id'
  ) THEN
    ALTER TABLE projects ADD COLUMN tpf_id text UNIQUE;
  END IF;
END $$;

-- Insert next_pod_number setting if it doesn't exist
INSERT INTO app_settings (key, value, updated_at)
VALUES ('next_pod_number', '1000', now())
ON CONFLICT (key) DO NOTHING;

-- Update RLS Policies for projects table
DROP POLICY IF EXISTS "Authenticated users can read projects" ON projects;
CREATE POLICY "Authenticated users can read projects"
  ON projects
  FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Admins can insert projects" ON projects;
CREATE POLICY "Admins can insert projects"
  ON projects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'Admin'
    )
  );

DROP POLICY IF EXISTS "Admins can update projects" ON projects;
CREATE POLICY "Admins can update projects"
  ON projects
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'Admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'Admin'
    )
  );

DROP POLICY IF EXISTS "Admins can delete projects" ON projects;
CREATE POLICY "Admins can delete projects"
  ON projects
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'Admin'
    )
  );