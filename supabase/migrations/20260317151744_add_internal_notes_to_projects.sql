/*
  # Add internal_notes column to projects

  ## Summary
  Adds a free-text `internal_notes` column to the `projects` table so engineers
  can record internal memos, questions, and updates against a project record.

  ## Changes
  - `projects` table
    - New column: `internal_notes` (text, nullable, default empty string)
      Stores unstructured internal engineering notes for a project.

  ## Notes
  - No RLS policy changes required — the existing project policies already govern
    SELECT/UPDATE on the `projects` table, so the new column is covered.
  - Nullable with a default of '' so existing rows are unaffected.
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'internal_notes'
  ) THEN
    ALTER TABLE projects ADD COLUMN internal_notes text NOT NULL DEFAULT '';
  END IF;
END $$;
