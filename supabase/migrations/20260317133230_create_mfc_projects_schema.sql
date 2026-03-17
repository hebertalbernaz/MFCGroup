/*
  # MFC Group Design System - Projects Schema

  ## Overview
  Creates the core data tables for the MFC Group project management tool.

  ## New Tables

  ### 1. `projects`
  The main projects table storing all client enquiries and project data.
  - `id` (uuid) - Primary key
  - `project_id` (text) - Human-readable ID like MFC-001 or POD-002
  - `client_name` (text) - Client's full name
  - `phone` (text) - Client phone number
  - `email` (text) - Client email address
  - `eircode` (text) - Irish postal code
  - `product_type` (text) - Either 'MFC' or 'POD'
  - `status` (text) - Kanban column status
  - `sequence_number` (integer) - Auto-incremented per product type for ID generation
  - `created_at` (timestamptz) - When the enquiry was created
  - `updated_at` (timestamptz) - Last update timestamp
  - `deadline` (timestamptz) - Project deadline date
  - `notes` (text) - Additional notes

  ### 2. `project_id_sequences`
  Tracks the last used sequence number per product type for ID generation.
  - `product_type` (text) - 'MFC' or 'POD'
  - `last_sequence` (integer) - Last used number

  ## Security
  - RLS enabled on both tables
  - Public read/write access policies (single-user local tool)
*/

CREATE TABLE IF NOT EXISTS projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id text UNIQUE NOT NULL,
  client_name text NOT NULL DEFAULT '',
  phone text NOT NULL DEFAULT '',
  email text NOT NULL DEFAULT '',
  eircode text NOT NULL DEFAULT '',
  product_type text NOT NULL DEFAULT 'MFC',
  status text NOT NULL DEFAULT 'new_enquiry',
  sequence_number integer NOT NULL DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  deadline timestamptz,
  notes text DEFAULT ''
);

CREATE TABLE IF NOT EXISTS project_id_sequences (
  product_type text PRIMARY KEY,
  last_sequence integer NOT NULL DEFAULT 0
);

INSERT INTO project_id_sequences (product_type, last_sequence)
VALUES ('MFC', 0), ('POD', 0)
ON CONFLICT (product_type) DO NOTHING;

ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_id_sequences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read on projects"
  ON projects FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow public insert on projects"
  ON projects FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Allow public update on projects"
  ON projects FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow public delete on projects"
  ON projects FOR DELETE
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow public read on sequences"
  ON project_id_sequences FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow public update on sequences"
  ON project_id_sequences FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_product_type ON projects(product_type);
CREATE INDEX IF NOT EXISTS idx_projects_created_at ON projects(created_at);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_projects_updated_at ON projects;
CREATE TRIGGER update_projects_updated_at
  BEFORE UPDATE ON projects
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
