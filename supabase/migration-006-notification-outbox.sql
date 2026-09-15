create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  channel text not null check (channel in ('email','whatsapp')),
  recipient text not null,
  subject text,
  message text not null,
  status text not null default 'queued' check (status in ('queued','sent','failed')),
  provider_response jsonb,
  created_by uuid references public.profiles(id),
  sent_at timestamptz,
  created_at timestamptz not null default now()
);
alter table public.notifications enable row level security;
drop policy if exists "staff notifications" on public.notifications;
create policy "staff notifications" on public.notifications for all using (public.is_staff()) with check (public.is_staff());
create index if not exists notifications_created_at_idx on public.notifications(created_at desc);
