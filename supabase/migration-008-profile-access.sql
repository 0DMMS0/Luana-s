-- Permite que cada sesión lea únicamente su perfil para resolver el rol.
alter table public.profiles enable row level security;
drop policy if exists "users read own profile" on public.profiles;
create policy "users read own profile" on public.profiles for select using (auth.uid()=id);
