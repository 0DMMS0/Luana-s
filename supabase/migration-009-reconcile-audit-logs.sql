-- Reconciles the two historical audit_logs shapes before production deployment.
-- Safe to run after migrations 001-008.
alter table public.audit_logs add column if not exists tenant_id uuid references public.tenants(id) on delete cascade;
alter table public.audit_logs add column if not exists entity_type text;
alter table public.audit_logs add column if not exists before_data jsonb;
alter table public.audit_logs add column if not exists after_data jsonb;

-- migration-002 used entity/details; the application uses entity_type/after_data.
do $$
begin
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='audit_logs' and column_name='entity') then
    update public.audit_logs set entity_type = coalesce(entity_type, entity) where entity_type is null and entity is not null;
    alter table public.audit_logs alter column entity drop not null;
  end if;
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='audit_logs' and column_name='details') then
    update public.audit_logs set after_data = coalesce(after_data, details) where after_data is null and details is not null;
  end if;
end $$;

update public.audit_logs set entity_type = 'unknown' where entity_type is null;
alter table public.audit_logs alter column entity_type set not null;

create index if not exists audit_logs_created_at_idx on public.audit_logs(created_at desc);
