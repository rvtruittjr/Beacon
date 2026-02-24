-- ============================================================
-- Beacøn — Social Accounts Table
-- ============================================================

create table public.social_accounts (
  id             uuid primary key default gen_random_uuid(),
  brand_id       uuid references public.brands(id) on delete cascade,
  platform       text not null,
  username       text not null,
  display_name   text,
  follower_count integer,
  profile_url    text,
  created_at     timestamptz default now()
);
alter table public.social_accounts enable row level security;
create policy "Social account access via brand ownership"
  on public.social_accounts for all
  using (exists (select 1 from public.brands where id = brand_id and user_id = auth.uid()));
