-- Add whiteboard item type and data columns to inspiration_items
ALTER TABLE inspiration_items
  ADD COLUMN type text NOT NULL DEFAULT 'image',
  ADD COLUMN data jsonb DEFAULT '{}';
