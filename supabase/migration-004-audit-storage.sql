-- Ikigai: auditoría y Storage. Ejecutar en Supabase SQL Editor.
create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references auth.users(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  before_data jsonb,
  after_data jsonb,
  created_at timestamptz not null default now()
);
alter table public.audit_logs enable row level security;
drop policy if exists "staff read audit logs" on public.audit_logs;
create policy "staff read audit logs" on public.audit_logs for select using (public.is_staff());
drop policy if exists "staff insert audit logs" on public.audit_logs;
create policy "staff insert audit logs" on public.audit_logs for insert with check (public.is_staff() and actor_id=auth.uid());

insert into storage.buckets (id,name,public) values ('ikigai-gallery','ikigai-gallery',true) on conflict (id) do update set public=true;
drop policy if exists "public read ikigai gallery" on storage.objects;
create policy "public read ikigai gallery" on storage.objects for select using (bucket_id='ikigai-gallery');
drop policy if exists "staff upload ikigai gallery" on storage.objects;
create policy "staff upload ikigai gallery" on storage.objects for insert with check (bucket_id='ikigai-gallery' and public.is_staff());
drop policy if exists "staff update ikigai gallery" on storage.objects;
create policy "staff update ikigai gallery" on storage.objects for update using (bucket_id='ikigai-gallery' and public.is_staff());
drop policy if exists "staff delete ikigai gallery" on storage.objects;
create policy "staff delete ikigai gallery" on storage.objects for delete using (bucket_id='ikigai-gallery' and public.is_staff());
