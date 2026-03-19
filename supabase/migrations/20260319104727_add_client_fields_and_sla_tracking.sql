/*
  # Add Client Fields and SLA Tracking to Projects
  
  ## Overview
  Extends the projects table with client contact information and SLA tracking capabilities.
  
  ## 1. Table Updates
  
  ### `projects` table additions
  - `email` (text) - Client email address
  - `phone` (text) - Client phone number
  - `address` (text) - Client physical address
  - `eircode` (text) - Irish postal code (Eircode)
  - `pod_model` (text) - POD model type (e.g., "POD 17", "Custom")
  - `status_updated_at` (timestamptz) - Timestamp for SLA tracking
  
  ## 2. Important Notes
  - All new fields are optional to maintain compatibility with existing records
  - `status_updated_at` defaults to now() for new records
  - Default values set to empty strings for text fields to simplify UI handling
  - Uses timestamptz for timezone-aware date tracking
*/

-- Add client contact fields to projects table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'email'
  ) THEN
    ALTER TABLE projects ADD COLUMN email text DEFAULT '';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'phone'
  ) THEN
    ALTER TABLE projects ADD COLUMN phone text DEFAULT '';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'address'
  ) THEN
    ALTER TABLE projects ADD COLUMN address text DEFAULT '';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'eircode'
  ) THEN
    ALTER TABLE projects ADD COLUMN eircode text DEFAULT '';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'pod_model'
  ) THEN
    ALTER TABLE projects ADD COLUMN pod_model text DEFAULT '';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'status_updated_at'
  ) THEN
    ALTER TABLE projects ADD COLUMN status_updated_at timestamptz DEFAULT now();
  END IF;
END $$;

-- Update existing records to set status_updated_at to created_at if null
UPDATE projects
SET status_updated_at = created_at
WHERE status_updated_at IS NULL;

-- Create trigger to automatically update status_updated_at when status changes
CREATE OR REPLACE FUNCTION update_status_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    NEW.status_updated_at = now();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS projects_status_change ON projects;
CREATE TRIGGER projects_status_change
  BEFORE UPDATE ON projects
  FOR EACH ROW
  EXECUTE FUNCTION update_status_timestamp();