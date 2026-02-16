const { Client } = require('pg');

const connectionString = "postgresql://postgres.ddmeodlpdxgmadduwdas:92li!ra$Gu2@aws-0-us-west-2.pooler.supabase.com:6543/postgres?sslmode=require";

async function setup() {
  const client = new Client({
    connectionString,
    ssl: { rejectUnauthorized: false }
  });
  try {
    await client.connect();
    console.log('Connected to Supabase');

    // 1. Cleanup
    console.log('Cleaning up existing tables...');
    // Drop all tables in public schema
    await client.query(`
      DO $$ DECLARE
          r RECORD;
      BEGIN
          FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
              EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
          END LOOP;
      END $$;
    `);

    // 2. Create schema gym
    console.log('Creating schema gym...');
    await client.query('CREATE SCHEMA IF NOT EXISTS gym');

    // Set search path
    await client.query('SET search_path TO gym, public');

    // 3. Run the SQL from the spec
    console.log('Creating tables from spec...');
    const sql = `
-- 4.1 Extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pg_trgm SCHEMA public;

-- 4.2 Seguridad / Multi
CREATE TABLE IF NOT EXISTS gym.empresa (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre varchar(200) NOT NULL,
  estado varchar(20) NOT NULL DEFAULT 'ACTIVO',
  creado_at timestamptz NOT NULL DEFAULT now(),
  actualizado_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS gym.sucursal (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  nombre varchar(200) NOT NULL,
  direccion varchar(400),
  estado varchar(20) NOT NULL DEFAULT 'ACTIVO',
  config_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  creado_at timestamptz NOT NULL DEFAULT now(),
  actualizado_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_sucursal_empresa ON gym.sucursal(empresa_id);

CREATE TABLE IF NOT EXISTS gym.usuario (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  email varchar(200) NOT NULL,
  nombre varchar(200) NOT NULL,
  hash varchar(300) NOT NULL,
  estado varchar(20) NOT NULL DEFAULT 'ACTIVO',
  token_version int NOT NULL DEFAULT 1,
  ultimo_login_at timestamptz,
  creado_at timestamptz NOT NULL DEFAULT now(),
  actualizado_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_usuario_empresa_email ON gym.usuario(empresa_id, email);
CREATE INDEX IF NOT EXISTS idx_usuario_empresa ON gym.usuario(empresa_id);

CREATE TABLE IF NOT EXISTS gym.rol (
  id smallserial PRIMARY KEY,
  nombre varchar(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS gym.usuario_rol (
  usuario_id uuid NOT NULL REFERENCES gym.usuario(id) ON DELETE CASCADE,
  rol_id int NOT NULL REFERENCES gym.rol(id),
  PRIMARY KEY(usuario_id, rol_id)
);

CREATE TABLE IF NOT EXISTS gym.usuario_sucursal (
  usuario_id uuid NOT NULL REFERENCES gym.usuario(id) ON DELETE CASCADE,
  sucursal_id uuid NOT NULL REFERENCES gym.sucursal(id) ON DELETE CASCADE,
  PRIMARY KEY(usuario_id, sucursal_id)
);

-- 4.3 Clientes
CREATE TABLE IF NOT EXISTS gym.cliente (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  nombre varchar(250) NOT NULL,
  telefono varchar(60),
  email varchar(200),
  documento varchar(80),
  estado varchar(20) NOT NULL DEFAULT 'ACTIVO',
  creado_at timestamptz NOT NULL DEFAULT now(),
  actualizado_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_cliente_empresa ON gym.cliente(empresa_id);
CREATE INDEX IF NOT EXISTS idx_cliente_nombre_trgm ON gym.cliente USING gin (nombre gin_trgm_ops);

-- 4.4 Planes / Membresías
CREATE TABLE IF NOT EXISTS gym.plan_membresia (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  nombre varchar(150) NOT NULL,
  tipo varchar(20) NOT NULL, -- DIAS | VISITAS
  dias int,
  visitas int,
  precio_centavos bigint NOT NULL,
  estado varchar(20) NOT NULL DEFAULT 'ACTIVO',
  creado_at timestamptz NOT NULL DEFAULT now(),
  actualizado_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_plan_empresa ON gym.plan_membresia(empresa_id);

CREATE TABLE IF NOT EXISTS gym.membresia_cliente (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  cliente_id uuid NOT NULL REFERENCES gym.cliente(id),
  sucursal_id uuid NOT NULL REFERENCES gym.sucursal(id),
  plan_id uuid NOT NULL REFERENCES gym.plan_membresia(id),
  inicio date NOT NULL,
  fin date NOT NULL,
  estado varchar(20) NOT NULL DEFAULT 'ACTIVA',
  visitas_restantes int,
  observaciones varchar(500),
  creado_at timestamptz NOT NULL DEFAULT now(),
  actualizado_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_membresia_checkin ON gym.membresia_cliente(empresa_id, sucursal_id, cliente_id, fin DESC);
CREATE INDEX IF NOT EXISTS idx_membresia_estado_fin ON gym.membresia_cliente(empresa_id, sucursal_id, estado, fin);

-- 4.5 Asistencia
CREATE TABLE IF NOT EXISTS gym.asistencia (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  sucursal_id uuid NOT NULL REFERENCES gym.sucursal(id),
  cliente_id uuid NOT NULL REFERENCES gym.cliente(id),
  usuario_id uuid NOT NULL REFERENCES gym.usuario(id),
  fecha_hora timestamptz NOT NULL DEFAULT now(),
  resultado varchar(20) NOT NULL,
  nota varchar(300)
);
CREATE INDEX IF NOT EXISTS idx_asistencia_sucursal_fecha ON gym.asistencia(sucursal_id, fecha_hora DESC);

-- 4.6 Caja / Pagos
CREATE TABLE IF NOT EXISTS gym.caja (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  sucursal_id uuid NOT NULL REFERENCES gym.sucursal(id),
  usuario_id uuid NOT NULL REFERENCES gym.usuario(id),
  estado varchar(20) NOT NULL DEFAULT 'ABIERTA',
  apertura_at timestamptz NOT NULL DEFAULT now(),
  cierre_at timestamptz,
  monto_apertura_centavos bigint NOT NULL DEFAULT 0,
  monto_cierre_centavos bigint
);
CREATE INDEX IF NOT EXISTS idx_caja_sucursal_estado ON gym.caja(sucursal_id, estado);

-- Solo 1 caja ABIERTA por usuario+sucursal
CREATE UNIQUE INDEX IF NOT EXISTS uq_caja_abierta_unica
ON gym.caja(empresa_id, sucursal_id, usuario_id)
WHERE estado = 'ABIERTA';

CREATE TABLE IF NOT EXISTS gym.pago (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  sucursal_id uuid NOT NULL REFERENCES gym.sucursal(id),
  caja_id uuid NOT NULL REFERENCES gym.caja(id),
  cliente_id uuid REFERENCES gym.cliente(id),
  tipo varchar(30) NOT NULL, -- MEMBRESIA | PRODUCTO | OTRO
  referencia_id uuid, -- membresia_cliente.id o venta.id
  monto_centavos bigint NOT NULL,
  metodo varchar(30) NOT NULL, -- EFECTIVO/TARJETA/TRANSFERENCIA/OTRO
  referencia varchar(120),
  estado varchar(20) NOT NULL DEFAULT 'APLICADO',
  creado_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_pago_caja_fecha ON gym.pago(caja_id, creado_at DESC);

-- 4.7 Productos / Inventario
CREATE TABLE IF NOT EXISTS gym.producto (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  nombre varchar(200) NOT NULL,
  categoria varchar(100),
  precio_centavos bigint NOT NULL,
  costo_centavos bigint NOT NULL DEFAULT 0,
  estado varchar(20) NOT NULL DEFAULT 'ACTIVO',
  creado_at timestamptz NOT NULL DEFAULT now(),
  actualizado_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_producto_empresa ON gym.producto(empresa_id);

CREATE TABLE IF NOT EXISTS gym.inventario_sucursal (
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  sucursal_id uuid NOT NULL REFERENCES gym.sucursal(id),
  producto_id uuid NOT NULL REFERENCES gym.producto(id),
  existencia numeric(12,2) NOT NULL DEFAULT 0,
  actualizado_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (sucursal_id, producto_id),
  CHECK (existencia >= 0)
);

-- 4.8 Ventas
CREATE TABLE IF NOT EXISTS gym.venta (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  sucursal_id uuid NOT NULL REFERENCES gym.sucursal(id),
  caja_id uuid NOT NULL REFERENCES gym.caja(id),
  cliente_id uuid REFERENCES gym.cliente(id),
  total_centavos bigint NOT NULL,
  estado varchar(20) NOT NULL DEFAULT 'APLICADA',
  creado_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_venta_caja_fecha ON gym.venta(caja_id, creado_at DESC);
CREATE INDEX IF NOT EXISTS idx_venta_sucursal_fecha ON gym.venta(sucursal_id, creado_at DESC);

CREATE TABLE IF NOT EXISTS gym.venta_detalle (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  venta_id uuid NOT NULL REFERENCES gym.venta(id) ON DELETE CASCADE,
  producto_id uuid NOT NULL REFERENCES gym.producto(id),
  cantidad numeric(12,2) NOT NULL,
  precio_unit_centavos bigint NOT NULL,
  subtotal_centavos bigint NOT NULL
);

CREATE TABLE IF NOT EXISTS gym.movimiento_inventario (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  sucursal_id uuid NOT NULL REFERENCES gym.sucursal(id),
  producto_id uuid NOT NULL REFERENCES gym.producto(id),
  tipo varchar(30) NOT NULL, -- ENTRADA/SALIDA/AJUSTE/TRASLADO_SALIDA/TRASLADO_ENTRADA
  cantidad numeric(12,2) NOT NULL,
  ref_tipo varchar(30), -- VENTA/AJUSTE/TRASLADO
  ref_id uuid,
  usuario_id uuid NOT NULL REFERENCES gym.usuario(id),
  creado_at timestamptz NOT NULL DEFAULT now(),
  payload_json jsonb NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX IF NOT EXISTS idx_mov_inv_sucursal_fecha ON gym.movimiento_inventario(sucursal_id, creado_at DESC);

-- 4.9 Sync / Idempotencia / Auditoría
CREATE TABLE IF NOT EXISTS gym.sync_request_procesado (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  usuario_id uuid NOT NULL REFERENCES gym.usuario(id),
  device_id varchar(80) NOT NULL,
  request_id varchar(80) NOT NULL,
  creado_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(empresa_id, device_id, request_id)
);

CREATE TABLE IF NOT EXISTS gym.bitacora (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  usuario_id uuid NOT NULL REFERENCES gym.usuario(id),
  entidad varchar(60) NOT NULL,
  entidad_id uuid,
  accion varchar(40) NOT NULL,
  creado_at timestamptz NOT NULL DEFAULT now(),
  json_data jsonb NOT NULL DEFAULT '{}'::jsonb
);

-- 4.10 Sync rápido: Change-Log central
CREATE TABLE IF NOT EXISTS gym.cambio_log (
  seq bigserial PRIMARY KEY,
  empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
  sucursal_id uuid REFERENCES gym.sucursal(id),
  entidad varchar(40) NOT NULL,   -- CLIENTE/MEMBRESIA/PRODUCTO/INVENTARIO/CAJA/PAGO/VENTA/ASISTENCIA/USUARIO
  entidad_id uuid,
  accion varchar(20) NOT NULL,    -- UPSERT/DELETE/ANULAR/ESTADO
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  creado_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_cambio_empresa_seq ON gym.cambio_log(empresa_id, seq);
CREATE INDEX IF NOT EXISTS idx_cambio_sucursal_seq ON gym.cambio_log(sucursal_id, seq);

-- 4.11 Triggers básicos para log (ejemplo cliente)
CREATE OR REPLACE FUNCTION gym.fn_log_cliente() RETURNS trigger AS $$
BEGIN
  INSERT INTO gym.cambio_log(empresa_id, sucursal_id, entidad, entidad_id, accion, payload)
  VALUES (
    NEW.empresa_id,
    NULL,
    'CLIENTE',
    NEW.id,
    'UPSERT',
    jsonb_build_object(
      'id', NEW.id,
      'empresa_id', NEW.empresa_id,
      'nombre', NEW.nombre,
      'telefono', NEW.telefono,
      'email', NEW.email,
      'documento', NEW.documento,
      'estado', NEW.estado,
      'actualizado_at', NEW.actualizado_at
    )
  );
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_cliente ON gym.cliente;
CREATE TRIGGER trg_log_cliente
AFTER INSERT OR UPDATE ON gym.cliente
FOR EACH ROW EXECUTE FUNCTION gym.fn_log_cliente();
    `;
    await client.query(sql);

    // 4. Seeds
    console.log('Seeding initial data...');
    await client.query(`
      INSERT INTO gym.rol(nombre) VALUES
      ('ADMIN'),('CAJA'),('RECEPCION'),('INVENTARIO')
      ON CONFLICT DO NOTHING;
    `);

    console.log('Database setup completed successfully.');
  } catch (err) {
    console.error('Error during database setup:', err);
  } finally {
    await client.end();
  }
}

setup();
