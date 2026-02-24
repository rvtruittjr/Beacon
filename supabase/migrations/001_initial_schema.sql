-- ============================================================
-- Beacøn — Initial Schema Migration
-- Run this in Supabase SQL Editor in one go
-- ============================================================

-- USERS
create table public.users (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text not null,
  full_name   text,
  avatar_url  text,
  created_at  timestamptz default now()
);
alter table public.users enable row level security;
create policy "Users can view and edit own profile"
  on public.users for all using (auth.uid() = id);

-- Auto-create user row on signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.users (id, email)
  values (new.id, new.email);
  return new;
end;
$$;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- BRANDS
create table public.brands (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid references public.users(id) on delete cascade,
  name                text not null,
  description         text,
  slug                text unique,
  share_token         text unique default gen_random_uuid()::text,
  is_public           boolean default false,
  share_password_hash text,
  share_expires_at    timestamptz,
  onboarding_complete boolean default false,
  created_at          timestamptz default now()
);
alter table public.brands enable row level security;
create policy "Users own their brands"
  on public.brands for all using (auth.uid() = user_id);

-- BRAND COLORS
create table public.brand_colors (
  id         uuid primary key default gen_random_uuid(),
  brand_id   uuid references public.brands(id) on delete cascade,
  label      text,
  hex        text not null,
  sort_order integer default 0,
  created_at timestamptz default now()
);
alter table public.brand_colors enable row level security;
create policy "Color access via brand ownership"
  on public.brand_colors for all
  using (exists (select 1 from public.brands where id = brand_id and user_id = auth.uid()));

-- BRAND FONTS
create table public.brand_fonts (
  id         uuid primary key default gen_random_uuid(),
  brand_id   uuid references public.brands(id) on delete cascade,
  label      text,
  family     text not null,
  weight     text,
  source     text,
  url        text,
  sort_order integer default 0
);
alter table public.brand_fonts enable row level security;
create policy "Font access via brand ownership"
  on public.brand_fonts for all
  using (exists (select 1 from public.brands where id = brand_id and user_id = auth.uid()));

-- ASSET COLLECTIONS
create table public.asset_collections (
  id          uuid primary key default gen_random_uuid(),
  brand_id    uuid references public.brands(id) on delete cascade,
  name        text not null,
  description text,
  sort_order  integer default 0,
  created_at  timestamptz default now()
);
alter table public.asset_collections enable row level security;
create policy "Collection access via brand ownership"
  on public.asset_collections for all
  using (exists (select 1 from public.brands where id = brand_id and user_id = auth.uid()));

-- ASSETS
create table public.assets (
  id              uuid primary key default gen_random_uuid(),
  brand_id        uuid references public.brands(id) on delete cascade,
  collection_id   uuid references public.asset_collections(id) on delete set null,
  user_id         uuid references public.users(id),
  name            text not null,
  description     text,
  file_url        text not null,
  thumbnail_url   text,
  file_type       text,
  mime_type       text,
  file_size_bytes bigint,
  width           integer,
  height          integer,
  is_archived     boolean default false,
  created_at      timestamptz default now()
);
alter table public.assets enable row level security;
create policy "Asset access via brand ownership"
  on public.assets for all
  using (exists (select 1 from public.brands where id = brand_id and user_id = auth.uid()));

-- TAGS
create table public.tags (
  id      uuid primary key default gen_random_uuid(),
  user_id uuid references public.users(id) on delete cascade,
  name    text not null,
  unique (user_id, name)
);
alter table public.tags enable row level security;
create policy "Users own their tags"
  on public.tags for all using (auth.uid() = user_id);

create table public.asset_tags (
  asset_id uuid references public.assets(id) on delete cascade,
  tag_id   uuid references public.tags(id) on delete cascade,
  primary key (asset_id, tag_id)
);
alter table public.asset_tags enable row level security;
create policy "Asset tag access via asset ownership"
  on public.asset_tags for all
  using (exists (
    select 1 from public.assets a
    join public.brands b on a.brand_id = b.id
    where a.id = asset_id and b.user_id = auth.uid()
  ));

-- BRAND VOICE
create table public.brand_voice (
  id                uuid primary key default gen_random_uuid(),
  brand_id          uuid unique references public.brands(id) on delete cascade,
  archetype         text,
  personality_tags  text[],
  tone_formal       integer default 5 check (tone_formal between 1 and 10),
  tone_serious      integer default 5 check (tone_serious between 1 and 10),
  tone_bold         integer default 5 check (tone_bold between 1 and 10),
  voice_summary     text,
  mission_statement text,
  tagline           text,
  words_we_use      text[],
  words_we_avoid    text[],
  updated_at        timestamptz default now()
);
alter table public.brand_voice enable row level security;
create policy "Voice access via brand ownership"
  on public.brand_voice for all
  using (exists (select 1 from public.brands where id = brand_id and user_id = auth.uid()));

-- BRAND VOICE EXAMPLES
create table public.brand_voice_examples (
  id         uuid primary key default gen_random_uuid(),
  brand_id   uuid references public.brands(id) on delete cascade,
  type       text,
  platform   text,
  label      text,
  content    text not null,
  notes      text,
  created_at timestamptz default now()
);
alter table public.brand_voice_examples enable row level security;
create policy "Voice examples access via brand ownership"
  on public.brand_voice_examples for all
  using (exists (select 1 from public.brands where id = brand_id and user_id = auth.uid()));

-- BRAND AUDIENCE
create table public.brand_audience (
  id              uuid primary key default gen_random_uuid(),
  brand_id        uuid unique references public.brands(id) on delete cascade,
  age_range_min   integer,
  age_range_max   integer,
  gender_skew     text,
  locations       text[],
  interests       text[],
  pain_points     text[],
  goals           text[],
  persona_name    text,
  persona_summary text,
  updated_at      timestamptz default now()
);
alter table public.brand_audience enable row level security;
create policy "Audience access via brand ownership"
  on public.brand_audience for all
  using (exists (select 1 from public.brands where id = brand_id and user_id = auth.uid()));

-- CONTENT PILLARS
create table public.content_pillars (
  id          uuid primary key default gen_random_uuid(),
  brand_id    uuid references public.brands(id) on delete cascade,
  name        text not null,
  description text,
  color       text,
  sort_order  integer default 0,
  created_at  timestamptz default now()
);
alter table public.content_pillars enable row level security;
create policy "Pillar access via brand ownership"
  on public.content_pillars for all
  using (exists (select 1 from public.brands where id = brand_id and user_id = auth.uid()));

-- BRAND GUIDELINES
create table public.brand_guidelines (
  id         uuid primary key default gen_random_uuid(),
  brand_id   uuid references public.brands(id) on delete cascade,
  section    text not null,
  content    text not null,
  sort_order integer default 0,
  created_at timestamptz default now()
);
alter table public.brand_guidelines enable row level security;
create policy "Guidelines access via brand ownership"
  on public.brand_guidelines for all
  using (exists (select 1 from public.brands where id = brand_id and user_id = auth.uid()));

-- CONTENT ARCHIVE
create table public.content_archive (
  id            uuid primary key default gen_random_uuid(),
  brand_id      uuid references public.brands(id) on delete cascade,
  pillar_id     uuid references public.content_pillars(id) on delete set null,
  title         text not null,
  platform      text,
  content_url   text,
  thumbnail_url text,
  video_url     text,
  hook          text,
  notes         text,
  posted_at     date,
  views         bigint,
  likes         bigint,
  comments      bigint,
  created_at    timestamptz default now()
);
alter table public.content_archive enable row level security;
create policy "Archive access via brand ownership"
  on public.content_archive for all
  using (exists (select 1 from public.brands where id = brand_id and user_id = auth.uid()));

-- BRAND SHARE ACCESS LOG
create table public.brand_share_access (
  id          uuid primary key default gen_random_uuid(),
  brand_id    uuid references public.brands(id) on delete cascade,
  accessed_at timestamptz default now(),
  ip_address  text,
  user_agent  text,
  granted     boolean
);
alter table public.brand_share_access enable row level security;
create policy "Share log access via brand ownership"
  on public.brand_share_access for all
  using (exists (select 1 from public.brands where id = brand_id and user_id = auth.uid()));

-- SUBSCRIPTIONS
create table public.subscriptions (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid unique references public.users(id) on delete cascade,
  stripe_customer_id text unique,
  stripe_sub_id      text unique,
  plan               text default 'free',
  status             text default 'active',
  current_period_end timestamptz,
  created_at         timestamptz default now()
);
alter table public.subscriptions enable row level security;
create policy "Users own their subscription"
  on public.subscriptions for all using (auth.uid() = user_id);

-- Auto-create free subscription on user creation
create or replace function public.handle_new_subscription()
returns trigger language plpgsql security definer as $$
begin
  insert into public.subscriptions (user_id, plan, status)
  values (new.id, 'free', 'active');
  return new;
end;
$$;
create trigger on_user_created_subscription
  after insert on public.users
  for each row execute procedure public.handle_new_subscription();
