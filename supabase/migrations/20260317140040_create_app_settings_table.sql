/*
  # App Settings Table

  ## Overview
  Stores application-level configuration as key/value pairs.
  Used primarily for folder path settings (template and destination drives).

  ## New Tables

  ### `app_settings`
  - `key` (text, primary key) — setting name
  - `value` (text) — setting value
  - `updated_at` (timestamptz) — last modified timestamp

  ## Initial Data
  Seeds the three required path settings with empty defaults.

  ## Security
  - RLS enabled; anon/authenticated users can read and write (single-user local tool)
*/

CREATE TABLE IF NOT EXISTS app_settings (
  key text PRIMARY KEY,
  value text NOT NULL DEFAULT '',
  updated_at timestamptz DEFAULT now()
);

INSERT INTO app_settings (key, value)
VALUES
  ('mfc_template_path', ''),
  ('pod_template_path', ''),
  ('destination_drive_path', '')
ON CONFLICT (key) DO NOTHING;

ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read on app_settings"
  ON app_settings FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow public update on app_settings"
  ON app_settings FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow public insert on app_settings"
  ON app_settings FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE OR REPLACE FUNCTION update_app_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_app_settings_updated_at ON app_settings;
CREATE TRIGGER update_app_settings_updated_at
  BEFORE UPDATE ON app_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_app_settings_updated_at();
