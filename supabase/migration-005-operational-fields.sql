-- Campos operativos usados por los formularios reales de Ikigai.
alter table public.students add column if not exists birth_date date;
alter table public.students add column if not exists address text;
alter table public.students add column if not exists membership_id uuid references public.memberships(id) on delete set null;
alter table public.students add column if not exists membership_started_at date;
alter table public.students add column if not exists membership_expires_at date;
alter table public.students add column if not exists membership_status text default 'pending';

alter table public.memberships add column if not exists billing_period text default 'monthly';
alter table public.memberships add column if not exists enrollment_fee numeric(12,2) default 0;
alter table public.memberships add column if not exists class_limit integer;
alter table public.memberships add column if not exists auto_renew boolean default false;
alter table public.memberships add column if not exists frozen_until date;

alter table public.classes add column if not exists end_time time;
alter table public.classes add column if not exists recurrence_type text default 'none';
alter table public.classes add column if not exists recurrence_until date;
alter table public.classes add column if not exists min_age integer;
alter table public.classes add column if not exists max_age integer;
alter table public.classes add column if not exists waitlist_enabled boolean default false;

alter table public.payments add column if not exists payment_method text default 'cash';
alter table public.payments add column if not exists receipt_number text;
alter table public.expenses add column if not exists category text;

create index if not exists students_membership_id_idx on public.students(membership_id);
create index if not exists classes_schedule_idx on public.classes(class_date, start_time);
create index if not exists payments_paid_at_idx on public.payments(paid_at);
