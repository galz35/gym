const postgres = require('postgres');
require('dotenv').config();

const url = process.env.DATABASE_URL || 'postgresql://alacaja:TuClaveFuerte@127.0.0.1:5432/gym_db';
const sql = postgres(url, { max: 1 });

async function migrate() {
  try {
    console.log(`Conectando a la base de datos: ${url.replace(/:[^:@]+@/, ':***@')}`);

    await sql.unsafe(`
      CREATE SCHEMA IF NOT EXISTS gym;
      SET search_path TO gym;

      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
      CREATE EXTENSION IF NOT EXISTS pg_trgm;

      CREATE TABLE IF NOT EXISTS sistema_status (
        id int PRIMARY KEY,
        activo boolean NOT NULL,
        nombre varchar(100)
      );

      CREATE TABLE IF NOT EXISTS empresa (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        nombre varchar(200) NOT NULL,
        estado varchar(20) NOT NULL DEFAULT 'ACTIVO',
        creado_at timestamptz NOT NULL DEFAULT now(),
        actualizado_at timestamptz NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS sucursal (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        nombre varchar(200) NOT NULL,
        direccion varchar(400),
        estado varchar(20) NOT NULL DEFAULT 'ACTIVO',
        config_json jsonb NOT NULL DEFAULT '{}'::jsonb,
        creado_at timestamptz NOT NULL DEFAULT now(),
        actualizado_at timestamptz NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS usuario (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        email varchar(200) NOT NULL,
        nombre varchar(200) NOT NULL,
        hash varchar(300) NOT NULL,
        estado varchar(20) NOT NULL DEFAULT 'ACTIVO',
        token_version int NOT NULL DEFAULT 1,
        ultimo_login_at timestamptz,
        creado_at timestamptz NOT NULL DEFAULT now(),
        actualizado_at timestamptz NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS rol (
        id smallserial PRIMARY KEY,
        nombre varchar(50) NOT NULL UNIQUE
      );

      CREATE TABLE IF NOT EXISTS usuario_rol (
        usuario_id uuid NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
        rol_id int NOT NULL REFERENCES rol(id),
        PRIMARY KEY(usuario_id, rol_id)
      );

      CREATE TABLE IF NOT EXISTS usuario_sucursal (
        usuario_id uuid NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
        sucursal_id uuid NOT NULL REFERENCES sucursal(id) ON DELETE CASCADE,
        PRIMARY KEY(usuario_id, sucursal_id)
      );

      CREATE TABLE IF NOT EXISTS cliente (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        nombre varchar(250) NOT NULL,
        telefono varchar(60),
        email varchar(200),
        documento varchar(80),
        estado varchar(20) NOT NULL DEFAULT 'ACTIVO',
        foto_url text,
        creado_at timestamptz NOT NULL DEFAULT now(),
        actualizado_at timestamptz NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS plan_membresia (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        nombre varchar(150) NOT NULL,
        tipo varchar(20) NOT NULL, 
        dias int,
        visitas int,
        precio_centavos bigint NOT NULL,
        estado varchar(20) NOT NULL DEFAULT 'ACTIVO',
        creado_at timestamptz NOT NULL DEFAULT now(),
        actualizado_at timestamptz NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS membresia_cliente (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        cliente_id uuid NOT NULL REFERENCES cliente(id),
        sucursal_id uuid NOT NULL REFERENCES sucursal(id),
        plan_id uuid NOT NULL REFERENCES plan_membresia(id),
        inicio date NOT NULL,
        fin date NOT NULL,
        estado varchar(20) NOT NULL DEFAULT 'ACTIVA',
        visitas_restantes int,
        observaciones varchar(500),
        creado_at timestamptz NOT NULL DEFAULT now(),
        actualizado_at timestamptz NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS asistencia (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        sucursal_id uuid NOT NULL REFERENCES sucursal(id),
        cliente_id uuid NOT NULL REFERENCES cliente(id),
        usuario_id uuid NOT NULL REFERENCES usuario(id),
        fecha_hora timestamptz NOT NULL DEFAULT now(),
        resultado varchar(20) NOT NULL,
        nota varchar(300),
        motivo varchar(200),
        notas varchar(300)
      );

      CREATE TABLE IF NOT EXISTS caja (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        sucursal_id uuid NOT NULL REFERENCES sucursal(id),
        usuario_id uuid NOT NULL REFERENCES usuario(id),
        estado varchar(20) NOT NULL DEFAULT 'ABIERTA',
        apertura_at timestamptz NOT NULL DEFAULT now(),
        cierre_at timestamptz,
        monto_apertura_centavos bigint NOT NULL DEFAULT 0,
        monto_cierre_centavos bigint
      );

      CREATE TABLE IF NOT EXISTS pago (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        sucursal_id uuid NOT NULL REFERENCES sucursal(id),
        caja_id uuid NOT NULL REFERENCES caja(id),
        cliente_id uuid REFERENCES cliente(id),
        tipo varchar(30) NOT NULL, 
        referencia_id uuid, 
        monto_centavos bigint NOT NULL,
        metodo varchar(30) NOT NULL, 
        referencia varchar(120),
        estado varchar(20) NOT NULL DEFAULT 'APLICADO',
        creado_at timestamptz NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS producto (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        nombre varchar(200) NOT NULL,
        categoria varchar(100),
        precio_centavos bigint NOT NULL,
        costo_centavos bigint NOT NULL DEFAULT 0,
        estado varchar(20) NOT NULL DEFAULT 'ACTIVO',
        creado_at timestamptz NOT NULL DEFAULT now(),
        actualizado_at timestamptz NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS inventario_sucursal (
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        sucursal_id uuid NOT NULL REFERENCES sucursal(id),
        producto_id uuid NOT NULL REFERENCES producto(id),
        existencia numeric(12,2) NOT NULL DEFAULT 0,
        actualizado_at timestamptz NOT NULL DEFAULT now(),
        PRIMARY KEY (sucursal_id, producto_id),
        CHECK (existencia >= 0)
      );

      CREATE TABLE IF NOT EXISTS venta (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        sucursal_id uuid NOT NULL REFERENCES sucursal(id),
        caja_id uuid NOT NULL REFERENCES caja(id),
        cliente_id uuid REFERENCES cliente(id),
        total_centavos bigint NOT NULL,
        estado varchar(20) NOT NULL DEFAULT 'APLICADA',
        creado_at timestamptz NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS venta_detalle (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        venta_id uuid NOT NULL REFERENCES venta(id) ON DELETE CASCADE,
        producto_id uuid NOT NULL REFERENCES producto(id),
        cantidad numeric(12,2) NOT NULL,
        precio_unit_centavos bigint NOT NULL,
        subtotal_centavos bigint NOT NULL
      );

      CREATE TABLE IF NOT EXISTS movimiento_inventario (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        sucursal_id uuid NOT NULL REFERENCES sucursal(id),
        producto_id uuid NOT NULL REFERENCES producto(id),
        tipo varchar(30) NOT NULL, 
        cantidad numeric(12,2) NOT NULL,
        ref_tipo varchar(30), 
        ref_id uuid,
        usuario_id uuid NOT NULL REFERENCES usuario(id),
        creado_at timestamptz NOT NULL DEFAULT now(),
        payload_json jsonb NOT NULL DEFAULT '{}'::jsonb
      );

      CREATE TABLE IF NOT EXISTS sync_request_procesado (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        usuario_id uuid NOT NULL REFERENCES usuario(id),
        device_id varchar(80) NOT NULL,
        request_id varchar(80) NOT NULL,
        creado_at timestamptz NOT NULL DEFAULT now(),
        UNIQUE(empresa_id, device_id, request_id)
      );

      CREATE TABLE IF NOT EXISTS evento_procesado (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        device_id varchar(80) NOT NULL,
        event_id varchar(80) NOT NULL,
        creado_at timestamptz NOT NULL DEFAULT now(),
        UNIQUE(empresa_id, device_id, event_id)
      );

      CREATE TABLE IF NOT EXISTS bitacora (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        usuario_id uuid NOT NULL REFERENCES usuario(id),
        entidad varchar(60) NOT NULL,
        entidad_id uuid,
        accion varchar(40) NOT NULL,
        creado_at timestamptz NOT NULL DEFAULT now(),
        json_data jsonb NOT NULL DEFAULT '{}'::jsonb
      );

      CREATE TABLE IF NOT EXISTS cambio_log (
        seq bigserial PRIMARY KEY,
        empresa_id uuid NOT NULL REFERENCES empresa(id),
        sucursal_id uuid REFERENCES sucursal(id),
        entidad varchar(40) NOT NULL,  
        entidad_id uuid,
        accion varchar(20) NOT NULL,   
        payload jsonb NOT NULL DEFAULT '{}'::jsonb,
        creado_at timestamptz NOT NULL DEFAULT now()
      );
    `);

    console.log('✅ Esquema y Tablas creadas correctamente en la base de datos "gym_db".');
  } catch (error) {
    console.error('❌ Error ejecutando la migración:', error);
  } finally {
    await sql.end();
  }
}

migrate();
