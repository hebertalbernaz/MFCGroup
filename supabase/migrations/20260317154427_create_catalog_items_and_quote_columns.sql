/*
  # Quoting Engine Phase 1 — Catalog Items & Project Quote Columns

  ## Summary
  Sets up the data foundation for the parametric quoting engine.

  ## New Tables

  ### `catalog_items`
  Stores the reusable item library that populates quote line items.
  - `id` (uuid, primary key)
  - `name` (text) — display name, e.g. "Base Build per m2"
  - `category` (text) — grouping, e.g. Structure / Insulation / Finishes / Appliances / Site Works
  - `unit_type` (text) — one of: m2, unit, linear_m, fixed
  - `base_cost` (numeric) — default unit cost in EUR
  - `sort_order` (integer) — display ordering within the catalog
  - `created_at` (timestamptz)

  ## Modified Tables

  ### `projects` — new quote parameter columns
  - `floor_area_sqm` (numeric, default 0) — project floor area in m²
  - `wall_area_sqm` (numeric, default 0) — total wall area in m²
  - `ceiling_area_sqm` (numeric, default 0) — ceiling area in m²
  - `base_price_per_sqm` (numeric, default 0) — override base price per m²
  - `markup_percentage` (numeric, default 20) — profit markup %
  - `contingency_percentage` (numeric, default 5) — contingency allowance %
  - `vat_percentage` (numeric, default 13.5) — Irish construction VAT rate
  - `quote_line_items` (jsonb, default []) — array of added line items for the quote

  ## Security
  - RLS enabled on `catalog_items`
  - Authenticated users can read all catalog items (shared library)
  - Authenticated users can insert, update, delete catalog items (admin operations)
  - No new RLS needed on `projects` columns (covered by existing project policies)

  ## Seed Data
  Pre-populates 7 Irish-specific catalog items as required.
*/

-- ─── catalog_items table ───────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS catalog_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL DEFAULT 'General',
  unit_type text NOT NULL DEFAULT 'unit',
  base_cost numeric(12, 2) NOT NULL DEFAULT 0,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE catalog_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read catalog items"
  ON catalog_items FOR SELECT
  TO authenticated
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can insert catalog items"
  ON catalog_items FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update catalog items"
  ON catalog_items FOR UPDATE
  TO authenticated
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete catalog items"
  ON catalog_items FOR DELETE
  TO authenticated
  USING (auth.uid() IS NOT NULL);

-- ─── Seed: Irish-specific pre-registered catalog items ─────────────────────

INSERT INTO catalog_items (name, category, unit_type, base_cost, sort_order)
SELECT name, category, unit_type, base_cost, sort_order FROM (VALUES
  ('Base Build per m2',             'Structure',   'm2',       1450.00, 10),
  ('Rockwool Insulation (m2)',      'Insulation',  'm2',         18.50, 20),
  ('EPS Insulation (m2)',           'Insulation',  'm2',         12.00, 30),
  ('Standard PVC Window (unit)',    'Finishes',    'unit',       850.00, 40),
  ('Crane Hire / Contract Lift',    'Site Works',  'fixed',     3200.00, 50),
  ('Wide Load Transport',           'Site Works',  'fixed',     1800.00, 60),
  ('ESB Connection Prep',           'Site Works',  'fixed',      950.00, 70)
) AS v(name, category, unit_type, base_cost, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM catalog_items LIMIT 1);

-- ─── projects: add quote parameter columns ─────────────────────────────────

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='projects' AND column_name='floor_area_sqm') THEN
    ALTER TABLE projects ADD COLUMN floor_area_sqm numeric(10,2) NOT NULL DEFAULT 0;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='projects' AND column_name='wall_area_sqm') THEN
    ALTER TABLE projects ADD COLUMN wall_area_sqm numeric(10,2) NOT NULL DEFAULT 0;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='projects' AND column_name='ceiling_area_sqm') THEN
    ALTER TABLE projects ADD COLUMN ceiling_area_sqm numeric(10,2) NOT NULL DEFAULT 0;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='projects' AND column_name='base_price_per_sqm') THEN
    ALTER TABLE projects ADD COLUMN base_price_per_sqm numeric(10,2) NOT NULL DEFAULT 0;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='projects' AND column_name='markup_percentage') THEN
    ALTER TABLE projects ADD COLUMN markup_percentage numeric(5,2) NOT NULL DEFAULT 20;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='projects' AND column_name='contingency_percentage') THEN
    ALTER TABLE projects ADD COLUMN contingency_percentage numeric(5,2) NOT NULL DEFAULT 5;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='projects' AND column_name='vat_percentage') THEN
    ALTER TABLE projects ADD COLUMN vat_percentage numeric(5,2) NOT NULL DEFAULT 13.5;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='projects' AND column_name='quote_line_items') THEN
    ALTER TABLE projects ADD COLUMN quote_line_items jsonb NOT NULL DEFAULT '[]'::jsonb;
  END IF;
END $$;
