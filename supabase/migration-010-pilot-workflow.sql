-- Luana / Academia Ikigai: workflow piloto completo. Idempotente.
alter table public.students add column if not exists membership_id uuid references public.memberships(id) on delete set null;
alter table public.students add column if not exists membership_expires_at date;
alter table public.students add column if not exists membership_status text default 'active';
alter table public.memberships add column if not exists billing_period text default 'monthly';
alter table public.memberships add column if not exists enrollment_fee numeric default 0;
alter table public.memberships add column if not exists class_limit integer;
alter table public.memberships add column if not exists auto_renew boolean default true;
alter table public.classes add column if not exists recurrence_type text default 'none';
alter table public.classes add column if not exists recurrence_until date;
alter table public.classes add column if not exists waitlist_enabled boolean default false;
alter table public.payments add column if not exists payment_method text default 'cash';
alter table public.expenses add column if not exists category text default 'general';

create table if not exists public.class_reservations (
 id uuid primary key default gen_random_uuid(), class_id uuid not null references public.classes(id) on delete cascade,
 student_id uuid not null references public.students(id) on delete cascade, status text not null default 'booked',
 reserved_at timestamptz not null default now(), unique(class_id, student_id)
);
create table if not exists public.student_progress (
 id uuid primary key default gen_random_uuid(), student_id uuid not null references public.students(id) on delete cascade,
 belt text not null default 'Blanco', stripes integer not null default 0 check (stripes between 0 and 4),
 evaluation_date date not null default current_date, notes text, created_at timestamptz not null default now()
);
create table if not exists public.products (
 id uuid primary key default gen_random_uuid(), name text not null, sku text unique, category text default 'general',
 price numeric not null default 0, stock integer not null default 0, min_stock integer not null default 0,
 active boolean not null default true, created_at timestamptz not null default now()
);
create table if not exists public.inventory_movements (
 id uuid primary key default gen_random_uuid(), product_id uuid not null references public.products(id) on delete cascade,
 movement_type text not null, quantity integer not null, unit_price numeric default 0, note text, created_at timestamptz not null default now()
);
create table if not exists public.sales (
 id uuid primary key default gen_random_uuid(), student_id uuid references public.students(id) on delete set null,
 total numeric not null default 0, payment_method text default 'cash', status text default 'completed', created_at timestamptz not null default now()
);
create table if not exists public.sale_items (
 id uuid primary key default gen_random_uuid(), sale_id uuid not null references public.sales(id) on delete cascade,
 product_id uuid not null references public.products(id) on delete restrict, quantity integer not null check (quantity > 0), unit_price numeric not null default 0
);
create table if not exists public.audit_logs (
 id uuid primary key default gen_random_uuid(), actor_id uuid references auth.users(id) on delete set null,
 action text not null, entity_type text not null, entity_id uuid, after_data jsonb, created_at timestamptz not null default now()
);

do $$ declare t text; begin
 foreach t in array array['students','classes','attendance','payments','expenses','memberships','class_reservations','student_progress','products','inventory_movements','sales','sale_items','audit_logs'] loop
  execute format('alter table public.%I enable row level security', t);
  execute format('drop policy if exists pilot_authenticated_%I on public.%I', t, t);
  execute format('create policy pilot_authenticated_%I on public.%I for all to authenticated using (true) with check (true)', t, t);
 end loop;
end $$;

drop policy if exists pilot_storage_read on storage.objects;
create policy pilot_storage_read on storage.objects for select using (bucket_id = 'ikigai-gallery');
drop policy if exists pilot_storage_write on storage.objects;
create policy pilot_storage_write on storage.objects for all to authenticated using (bucket_id = 'ikigai-gallery') with check (bucket_id = 'ikigai-gallery');
