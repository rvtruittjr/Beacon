-- ============================================================
-- Beacøn — Storage Bucket Policies
-- Run AFTER creating the buckets in the Supabase Dashboard:
--   1. brand-assets (Private)
--   2. archive-media (Private)
-- ============================================================

-- brand-assets: users can CRUD files under their own user_id prefix
create policy "Users manage own brand assets"
  on storage.objects for all
  using (
    bucket_id = 'brand-assets'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'brand-assets'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- archive-media: users can CRUD files under their own user_id prefix
create policy "Users manage own archive media"
  on storage.objects for all
  using (
    bucket_id = 'archive-media'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'archive-media'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
