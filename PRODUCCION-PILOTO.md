# Luana · Academia Ikigai — salida del piloto

## Despliegue

El proyecto está preparado para Vercel con `vercel.json`. En el proyecto de producción configurar:

- `VITE_SUPABASE_URL=https://xeorqezrlnbfnmdpssxw.supabase.co`
- `VITE_SUPABASE_PUBLISHABLE_KEY=<clave anon/publishable de Supabase>`

Comandos de publicación:

```bash
npm ci
npm run build
npx vercel --prod
```

La clave publishable/anon puede estar en el frontend; nunca publicar una `service_role`.

## Respaldo básico

Supabase debe mantener los respaldos automáticos del proyecto activos. Antes de cada cambio de esquema, ejecutar un respaldo lógico desde el panel de Supabase o con un rol de base de datos autorizado. Conservar `supabase/migration-010-pilot-workflow.sql` y `supabase/seed-pilot.sql` versionados.

## Datos del piloto

Se conservan intencionalmente todos los registros `PRUEBA LUANA 2026`. Son datos de prueba identificables y no deben borrarse al publicar.

## Checklist de apertura

- [ ] Configurar variables en Vercel y publicar.
- [ ] Cambiar la contraseña inicial del administrador.
- [ ] Revisar políticas RLS en Supabase antes de hacer público el dominio.
- [ ] Probar desde un teléfono: login, clases, agenda, asistencia, progreso, pagos, tienda y reportes.
- [ ] Crear un registro temporal, editarlo y eliminarlo en cada módulo con CRUD.
- [ ] Confirmar dashboard y reportes con datos nuevos.
- [ ] Configurar dominio y HTTPS.
