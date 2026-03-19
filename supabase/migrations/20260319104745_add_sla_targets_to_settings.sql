/*
  # Add SLA Targets to System Settings
  
  ## Overview
  Adds Service Level Agreement (SLA) target configurations to the app_settings table.
  
  ## 1. New Settings
  
  ### SLA Targets (in days)
  - `sla_new_enquiry` (default: 2) - Days allowed for New Enquiry status
  - `sla_in_design` (default: 7) - Days allowed for In Design status
  - `sla_awaiting_quote` (default: 3) - Days allowed for Awaiting Quote status
  - `sla_revisions` (default: 5) - Days allowed for Revisions status
  
  ## 2. Important Notes
  - Values are stored as integers representing number of days
  - These settings allow managers to dynamically adjust team deadlines
  - Used for calculating SLA badge colors in the UI (red for overdue, green for on-time)
*/

-- Insert SLA target settings with default values
INSERT INTO app_settings (key, value, updated_at)
VALUES 
  ('sla_new_enquiry', '2', now()),
  ('sla_in_design', '7', now()),
  ('sla_awaiting_quote', '3', now()),
  ('sla_revisions', '5', now())
ON CONFLICT (key) DO NOTHING;