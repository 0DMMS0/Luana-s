-- Ikigai SaaS foundation. Apply after schema.sql and previous migrations.
-- Expand-only migration: nullable tenant_id columns allow staged backfill.
create table if not exists public.tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  country text default 'Costa Rica',
  currency text default 'CRC',
  timezone text default 'America/Costa_Rica',
  logo_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.branches (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  name text not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (tenant_id, name)
);

alter table public.profiles add column if not exists tenant_id uuid references public.tenants(id);
alter table public.profiles add column if not exists branch_id uuid references public.branches(id);
alter table public.profiles add column if not exists role_name text;
alter table public.students add column if not exists tenant_id uuid references public.tenants(id);
alter table public.students add column if not exists branch_id uuid references public.branches(id);
alter table public.classes add column if not exists tenant_id uuid references public.tenants(id);
alter table public.classes add column if not exists branch_id uuid references public.branches(id);
alter table public.attendance add column if not exists tenant_id uuid references public.tenants(id);
alter table public.payments add column if not exists tenant_id uuid references public.tenants(id);
alter table public.memberships add column if not exists tenant_id uuid references public.tenants(id);
alter table public.expenses add column if not exists tenant_id uuid references public.tenants(id);
alter table public.news add column if not exists tenant_id uuid references public.tenants(id);
alter table public.gallery add column if not exists tenant_id uuid references public.tenants(id);
alter table public.contact_messages add column if not exists tenant_id uuid references public.tenants(id);
alter table public.trial_bookings add column if not exists tenant_id uuid references public.tenants(id);

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.tenants(id) on delete cascade,
  actor_id uuid references auth.users(id),
  action text not null,
  entity_type text not null,
  entity_id uuid,
  before_data jsonb,
  after_data jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_profiles_tenant on public.profiles(tenant_id);
create index if not exists idx_students_tenant on public.students(tenant_id);
create index if not exists idx_classes_tenant_date on public.classes(tenant_id, class_date);
create index if not exists idx_payments_tenant_date on public.payments(tenant_id, paid_at);
create index if not exists idx_audit_logs_tenant_date on public.audit_logs(tenant_id, created_at desc);

alter table public.tenants enable row level security;
alter table public.branches enable row level security;
alter table public.audit_logs enable row level security;

create or replace function public.current_tenant_id() returns uuid
language sql stable security definer set search_path=public
as $$ select tenant_id from public.profiles where id=auth.uid() $$;

create policy "tenant members read own tenant" on public.tenants for select
using (id=public.current_tenant_id());
create policy "tenant members read branches" on public.branches for select
using (tenant_id=public.current_tenant_id());
create policy "staff read audit" on public.audit_logs for select
using (tenant_id=public.current_tenant_id() and exists(select 1 from public.profiles where id=auth.uid() and role in ('admin','instructor')));
