-- Ejecutar después del esquema inicial. Es segura para reintentar.
create table if not exists public.memberships (id uuid primary key default gen_random_uuid(), name text not null, amount numeric(12,2) not null, active boolean default true, created_by uuid references auth.users(id), created_at timestamptz default now());
create table if not exists public.expenses (id uuid primary key default gen_random_uuid(), concept text not null, amount numeric(12,2) not null, expense_date date default current_date, created_by uuid references auth.users(id), created_at timestamptz default now());
create table if not exists public.trial_bookings (id uuid primary key default gen_random_uuid(), name text not null, contact text, preferred_class text, status text default 'new', created_at timestamptz default now());
create table if not exists public.class_enrollments (id uuid primary key default gen_random_uuid(), class_name text not null, user_id uuid references auth.users(id) on delete cascade, created_at timestamptz default now(), unique(class_name,user_id));
create table if not exists public.contact_messages (id uuid primary key default gen_random_uuid(), name text not null, contact text not null, message text, created_at timestamptz default now());
alter table public.memberships enable row level security; alter table public.expenses enable row level security; alter table public.trial_bookings enable row level security; alter table public.class_enrollments enable row level security; alter table public.contact_messages enable row level security;
create or replace function public.is_staff() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.profiles p where p.id=auth.uid() and p.role in ('admin','instructor')); $$;
drop policy if exists "staff memberships" on public.memberships; create policy "staff memberships" on public.memberships for all using (public.is_staff()) with check (public.is_staff());
drop policy if exists "staff expenses" on public.expenses; create policy "staff expenses" on public.expenses for all using (public.is_staff()) with check (public.is_staff());
drop policy if exists "public trial bookings" on public.trial_bookings; create policy "public trial bookings" on public.trial_bookings for insert with check (true);
drop policy if exists "users enroll themselves" on public.class_enrollments; create policy "users enroll themselves" on public.class_enrollments for insert with check (auth.uid()=user_id);
drop policy if exists "users see own enrollments" on public.class_enrollments; create policy "users see own enrollments" on public.class_enrollments for select using (auth.uid()=user_id);
drop policy if exists "public contact messages" on public.contact_messages; create policy "public contact messages" on public.contact_messages for insert with check (true);
drop policy if exists "staff contact read" on public.contact_messages; create policy "staff contact read" on public.contact_messages for select using (public.is_staff());
-- Verifica que el perfil corresponda al mismo UUID de Authentication > Users:
select auth.uid() as current_user_id;
