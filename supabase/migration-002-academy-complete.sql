-- Ikigai: relaciones y reglas de negocio para la versión operativa.
alter table public.students add column if not exists user_id uuid references auth.users(id) on delete set null;
alter table public.students add column if not exists membership_id uuid references public.memberships(id) on delete set null;
alter table public.students add column if not exists membership_expires_at date;
alter table public.students add column if not exists updated_at timestamptz default now();
alter table public.payments add column if not exists payment_method text not null default 'efectivo';
alter table public.payments add column if not exists due_date date;
alter table public.payments add column if not exists receipt_number text default ('IK-' || substring(gen_random_uuid()::text,1,8));
alter table public.classes add column if not exists recurrence_type text default 'none';
alter table public.classes add column if not exists recurrence_until date;
alter table public.classes add column if not exists updated_at timestamptz default now();
alter table public.class_enrollments add column if not exists class_id uuid references public.classes(id) on delete cascade;
alter table public.class_enrollments add column if not exists status text default 'confirmed';
alter table public.attendance add column if not exists attendance_date date default current_date;
alter table public.news add column if not exists updated_at timestamptz default now();
alter table public.expenses add column if not exists updated_at timestamptz default now();

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(), actor_id uuid references auth.users(id) on delete set null,
  action text not null, entity text not null, entity_id uuid, details jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

create or replace function public.membership_status(expires date, paid boolean)
returns text language sql immutable as $$
  select case when expires is null then case when paid then 'al_dia' else 'pendiente' end
  when expires < current_date then 'vencido'
  when paid then 'al_dia' else 'pendiente' end
$$;

alter table public.audit_logs enable row level security;
drop policy if exists "staff audit read" on public.audit_logs;
create policy "staff audit read" on public.audit_logs for select using (public.is_staff());
drop policy if exists "staff audit insert" on public.audit_logs;
create policy "staff audit insert" on public.audit_logs for insert with check (public.is_staff() and actor_id=auth.uid());

drop policy if exists "users own student" on public.students;
create policy "users own student" on public.students for select using (user_id=auth.uid());
drop policy if exists "users own payments" on public.payments;
create policy "users own payments" on public.payments for select using (student_id in (select id from public.students where user_id=auth.uid()));

create index if not exists students_user_id_idx on public.students(user_id);
create index if not exists payments_student_id_idx on public.payments(student_id);
create index if not exists attendance_class_date_idx on public.attendance(class_id,attendance_date);
create index if not exists audit_logs_created_at_idx on public.audit_logs(created_at desc);
