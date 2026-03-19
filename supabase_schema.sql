-- ═══════════════════════════════════════════════════════════════
--  HUMAND CULTURELAB — Supabase Schema
--  Ejecutar en: Supabase → SQL Editor → Run
-- ═══════════════════════════════════════════════════════════════

-- 1. Dinámicas (trivias, pulsos, reconocimientos)
CREATE TABLE IF NOT EXISTS dinamicas (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tipo        TEXT NOT NULL CHECK (tipo IN ('daily_play','pulso','reconocimiento','mision')),
  nombre      TEXT NOT NULL,
  descripcion TEXT,
  estado      TEXT DEFAULT 'activa' CHECK (estado IN ('activa','inactiva','borrador','finalizada')),
  puntos_base INTEGER DEFAULT 10,
  created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deleted_at  TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

-- 2. Preguntas (para Daily Play)
CREATE TABLE IF NOT EXISTS preguntas (
  id                 UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  dinamica_id        UUID REFERENCES dinamicas(id) ON DELETE CASCADE,
  texto              TEXT NOT NULL,
  opciones           JSONB NOT NULL DEFAULT '[]',
  respuesta_correcta INTEGER DEFAULT 0,
  tiempo_segundos    INTEGER DEFAULT 15,
  orden              INTEGER DEFAULT 0,
  created_at         TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Respuestas de trivia
CREATE TABLE IF NOT EXISTS respuestas (
  id                UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  dinamica_id       UUID REFERENCES dinamicas(id),
  pregunta_id       UUID REFERENCES preguntas(id),
  empleado_nombre   TEXT NOT NULL,
  respuesta_elegida INTEGER,
  es_correcta       BOOLEAN,
  puntos_ganados    INTEGER DEFAULT 0,
  created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Respuestas de Pulso
CREATE TABLE IF NOT EXISTS pulso_respuestas (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  dinamica_id     UUID REFERENCES dinamicas(id),
  empleado_nombre TEXT,
  emoji           TEXT NOT NULL,
  sentimiento     TEXT,
  motivos         JSONB DEFAULT '[]',
  comentario      TEXT,
  anonimo         BOOLEAN DEFAULT true,
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Reconocimientos
CREATE TABLE IF NOT EXISTS reconocimientos (
  id                   UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  dinamica_id          UUID REFERENCES dinamicas(id),
  nominador_nombre     TEXT NOT NULL,
  nominado_nombre      TEXT NOT NULL,
  tipo_reconocimiento  TEXT,
  mensaje              TEXT,
  valores              JSONB DEFAULT '[]',
  created_at           TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Configuración
CREATE TABLE IF NOT EXISTS configuracion (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  clave      TEXT UNIQUE NOT NULL,
  valor      JSONB NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Rankings
CREATE TABLE IF NOT EXISTS rankings (
  id                     UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  empleado_nombre        TEXT UNIQUE NOT NULL,
  puntos_total           INTEGER DEFAULT 0,
  puntos_daily           INTEGER DEFAULT 0,
  puntos_pulso           INTEGER DEFAULT 0,
  puntos_reconocimiento  INTEGER DEFAULT 0,
  racha_dias             INTEGER DEFAULT 0,
  updated_at             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ── Habilitar acceso público (hackathon) ──────────────────────
ALTER TABLE dinamicas       ENABLE ROW LEVEL SECURITY;
ALTER TABLE preguntas       ENABLE ROW LEVEL SECURITY;
ALTER TABLE respuestas      ENABLE ROW LEVEL SECURITY;
ALTER TABLE pulso_respuestas ENABLE ROW LEVEL SECURITY;
ALTER TABLE reconocimientos ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuracion   ENABLE ROW LEVEL SECURITY;
ALTER TABLE rankings        ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_access" ON dinamicas        FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_access" ON preguntas        FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_access" ON respuestas       FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_access" ON pulso_respuestas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_access" ON reconocimientos  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_access" ON configuracion    FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_access" ON rankings         FOR ALL USING (true) WITH CHECK (true);

-- ── Datos iniciales ───────────────────────────────────────────
INSERT INTO configuracion (clave, valor) VALUES
  ('puntos_daily_play',   '{"base":10,"bonus_racha":5,"bonus_velocidad":3}'),
  ('puntos_pulso',        '{"base":5}'),
  ('puntos_reconocimiento','{"dar":3,"recibir":10}'),
  ('ranking_habilitado',  'true'),
  ('premios_habilitados', 'false')
ON CONFLICT (clave) DO NOTHING;

INSERT INTO rankings (empleado_nombre, puntos_total, puntos_daily, puntos_pulso, puntos_reconocimiento, racha_dias) VALUES
  ('Carolina Meoniz',  245, 120, 45, 80, 7),
  ('Valeria Andrade',  198,  95, 38, 65, 5),
  ('Daniela Soto',     187,  88, 42, 57, 4),
  ('Ricardo Jiménez',  156,  72, 34, 50, 3),
  ('María López',      134,  65, 29, 40, 6)
ON CONFLICT (empleado_nombre) DO NOTHING;
