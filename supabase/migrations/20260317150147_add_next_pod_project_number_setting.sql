/*
  # Add next_pod_project_number setting

  ## Summary
  Inserts the new `next_pod_project_number` key into the app_settings table.
  This is a completely independent counter from `next_pod_number` (which tracks
  POD Enquiries / PD IDs). Only ~10% of POD Enquiries become POD Projects, so
  the two sequences must never share a counter.

  ## New Settings Key
  - `next_pod_project_number` — starting value 42, incremented each time a POD
    enquiry is approved/signed and copied to the POD Projects folder as POD-XXXX.

  ## Existing Keys (unchanged)
  - `next_pod_number`    — counter for new POD Enquiries (PD prefix)
  - `next_mfc_number`    — counter for new MFC projects
*/

INSERT INTO app_settings (key, value)
VALUES ('next_pod_project_number', '42')
ON CONFLICT (key) DO NOTHING;
