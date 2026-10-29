-- Run in the SQL editor of the Supabase project used by iPhone Hub.
-- This stores app metadata and signed manifest links only. Never store P12 files or passwords here.

create table if not exists public.ios_hub_apps (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  icon_url text not null default '',
  manifest_url text not null,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  constraint ios_hub_manifest_https check (manifest_url ~* '^https://.+[.]plist([?].*)?$'),
  constraint ios_hub_icon_https check (icon_url = '' or icon_url ~* '^https://')
);

alter table public.ios_hub_apps enable row level security;

drop policy if exists "Public reads active iPhone Hub apps" on public.ios_hub_apps;
create policy "Public reads active iPhone Hub apps"
on public.ios_hub_apps for select to anon, authenticated
using (is_active);

drop policy if exists "Owner manages iPhone Hub apps" on public.ios_hub_apps;
create policy "Owner manages iPhone Hub apps"
on public.ios_hub_apps for all to authenticated
using (auth.uid() = 'f6211fb3-abff-4e3c-ac42-e55274d0fe03'::uuid)
with check (auth.uid() = 'f6211fb3-abff-4e3c-ac42-e55274d0fe03'::uuid);

grant select on public.ios_hub_apps to anon, authenticated;
grant insert, update, delete on public.ios_hub_apps to authenticated;
