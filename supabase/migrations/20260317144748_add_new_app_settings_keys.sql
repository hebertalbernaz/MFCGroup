/*
  # Add new app_settings keys for Phase 4 business rules

  1. New Settings Keys
    - `next_mfc_number` - Sequential integer counter for MFC project IDs, default 2000
    - `next_pod_number` - Sequential integer counter for POD project IDs, default 1000
    - `mfc_projects_path` - Destination folder path for MFC projects
    - `pod_enquiries_path` - Destination folder path for new POD enquiries
    - `pod_projects_path` - Destination folder path for approved/signed POD projects

  2. Notes
    - Uses INSERT ... ON CONFLICT DO NOTHING to safely seed defaults without overwriting existing values
    - Existing keys (mfc_template_path, pod_template_path, destination_drive_path) are preserved
*/

INSERT INTO app_settings (key, value) VALUES
  ('next_mfc_number', '2000'),
  ('next_pod_number', '1000'),
  ('mfc_projects_path', ''),
  ('pod_enquiries_path', ''),
  ('pod_projects_path', '')
ON CONFLICT (key) DO NOTHING;
