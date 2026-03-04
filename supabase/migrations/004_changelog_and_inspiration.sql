-- Brand Changelog: tracks mutations across brand kit entities
CREATE TABLE brand_changelog (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id uuid NOT NULL REFERENCES brands(id) ON DELETE CASCADE,
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_label text,
  details jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_changelog_brand ON brand_changelog(brand_id, created_at DESC);

ALTER TABLE brand_changelog ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Access via brand ownership"
  ON brand_changelog FOR ALL
  USING (brand_id IN (SELECT id FROM brands WHERE user_id = auth.uid()));

-- Inspiration Board: positioned mood board items
CREATE TABLE inspiration_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id uuid NOT NULL REFERENCES brands(id) ON DELETE CASCADE,
  image_url text NOT NULL,
  caption text,
  pos_x double precision NOT NULL DEFAULT 0,
  pos_y double precision NOT NULL DEFAULT 0,
  width double precision NOT NULL DEFAULT 200,
  height double precision NOT NULL DEFAULT 200,
  sort_order int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE inspiration_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Access via brand ownership"
  ON inspiration_items FOR ALL
  USING (brand_id IN (SELECT id FROM brands WHERE user_id = auth.uid()));
