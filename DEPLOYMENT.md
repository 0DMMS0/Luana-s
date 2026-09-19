# Despliegue de Ikigai

## 1. Supabase

1. Instala la CLI: `npm install --save-dev supabase`.
2. Autentícala: `npx supabase login`.
3. Vincula el proyecto existente: `npx supabase link --project-ref xeorqezrlnbfnmdpssxw`.
4. Ejecuta, en orden, `supabase/schema.sql` y las migraciones `migration-001` a `migration-009` en el SQL Editor. Son idempotentes donde corresponde; revisa los errores de objetos que ya existan.
5. Despliega la función: `npx supabase functions deploy send-notification`.
6. Carga secretos sin escribirlos en archivos: `npx supabase secrets set RESEND_API_KEY=... MAIL_FROM="Ikigai <no-reply@tudominio.com>"`. Para WhatsApp añade `WHATSAPP_TOKEN` y `WHATSAPP_PHONE_NUMBER_ID`.

### Administrador inicial

1. Crea el usuario en **Authentication → Users**.
2. En SQL Editor ejecuta, sustituyendo el UUID del usuario:

```sql
insert into public.profiles (id, full_name, role)
values ('USER_UUID', 'Administrador Ikigai', 'admin')
on conflict (id) do update set full_name = excluded.full_name, role = 'admin';
```

3. Inicia sesión y confirma que `#finanzas`, `#reportes` y `#configuracion` no muestran acceso restringido.

## 2. Vercel

1. Importa el repositorio Git en Vercel.
2. Añade en **Settings → Environment Variables** para Production, Preview y Development:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_PUBLISHABLE_KEY`
3. Despliega. Vercel usará `npm run build` y publicará `dist`.
4. En Supabase, añade la URL final de Vercel a **Authentication → URL Configuration** (Site URL y Redirect URLs).

## 3. Checklist de aceptación

- Login como admin y como usuario sin privilegios.
- Alta/edición/suspensión de alumno.
- Crear una clase y registrar asistencia.
- Registrar, liquidar y eliminar un pago de prueba.
- Subir y borrar una imagen de galería de prueba.
- Enviar un correo de prueba a un destinatario autorizado.
- Confirmar que no haya errores de RLS ni errores de CORS en consola.
