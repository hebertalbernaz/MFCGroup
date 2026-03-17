/*
  # Add Stock Tracking to Catalog Items

  ## Summary
  Adds inventory/stock tracking fields to the catalog_items table
  to support low-stock warnings in the Quote Builder.

  ## Modified Tables

  ### `catalog_items` — new stock columns
  - `track_stock` (boolean, default false) — whether stock levels are monitored for this item
  - `stock` (integer, default 0) — current stock quantity on hand

  ## Notes
  - Only items with `track_stock = true` will trigger low-stock warnings in the UI
  - Existing items receive `track_stock = false` by default (no behaviour change)
  - After adding columns, updates seed items: Windows and Sockets get low stock to demonstrate warnings
*/

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='catalog_items' AND column_name='track_stock') THEN
    ALTER TABLE catalog_items ADD COLUMN track_stock boolean NOT NULL DEFAULT false;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='catalog_items' AND column_name='stock') THEN
    ALTER TABLE catalog_items ADD COLUMN stock integer NOT NULL DEFAULT 0;
  END IF;
END $$;

UPDATE catalog_items SET track_stock = true, stock = 2 WHERE name ILIKE '%window%' AND track_stock = false;
UPDATE catalog_items SET track_stock = true, stock = 0 WHERE name ILIKE '%socket%' AND track_stock = false;
