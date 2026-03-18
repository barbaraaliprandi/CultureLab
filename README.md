# CultureLab — Humand Hackathon

Prototipo funcional del módulo **Cultural Engagement** de Humand.
Conecta un panel de administración web con una app mobile a través de Supabase.

## Estructura

```
CultureLab/
├── admin/index.html    → Panel admin (web desktop)
└── mobile/index.html   → App del empleado (mobile)
```

## Setup rápido

### 1. Configurar Supabase

Reemplazar en **ambos** HTMLs (línea ~414 en admin, ~839 en mobile):

```js
const SUPABASE_URL = 'https://YOUR_PROJECT_ID.supabase.co';
const SUPABASE_KEY = 'YOUR_ANON_PUBLIC_KEY';
```

### 2. Crear tablas en Supabase

Ejecutar el SQL del archivo `supabase_schema.sql` en el SQL Editor de Supabase.

### 3. Deploy en Vercel

- Conectar este repo en [vercel.com](https://vercel.com)
- URLs resultantes:
  - `https://your-app.vercel.app/admin/` → Admin
  - `https://your-app.vercel.app/mobile/` → Mobile

## Flujo Admin → Mobile

1. Admin crea una **dinámica** (trivia, pulso, reconocimiento) → se guarda en Supabase
2. Mobile carga las dinámicas activas desde Supabase
3. Empleado responde → puntos guardados en Supabase
4. Admin ve métricas en tiempo real en el Dashboard
