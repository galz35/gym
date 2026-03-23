const postgres = require('postgres');
const url = 'postgresql://alacaja:TuClaveFuerte@190.56.16.85:5432/gym_db';
const sql = postgres(url, { max: 1 });

async function fix() {
  try {
    console.log('Aplicando correcciones...\n');

    // 1. plan_membresia
    await sql.unsafe(`ALTER TABLE gym.plan_membresia ADD COLUMN IF NOT EXISTS sucursal_id uuid REFERENCES gym.sucursal(id);`);
    await sql.unsafe(`ALTER TABLE gym.plan_membresia ADD COLUMN IF NOT EXISTS descripcion text;`);
    await sql.unsafe(`ALTER TABLE gym.plan_membresia ADD COLUMN IF NOT EXISTS multisede boolean DEFAULT false;`);
    console.log('✅ plan_membresia corregida');

    // 2. cliente
    await sql.unsafe(`ALTER TABLE gym.cliente ADD COLUMN IF NOT EXISTS foto_url text;`);
    console.log('✅ cliente OK');

    // 3. asistencia
    await sql.unsafe(`ALTER TABLE gym.asistencia ADD COLUMN IF NOT EXISTS fecha_salida timestamptz;`);
    console.log('✅ asistencia OK');

    // 4. caja
    await sql.unsafe(`ALTER TABLE gym.caja ADD COLUMN IF NOT EXISTS diferencia_centavos bigint;`);
    await sql.unsafe(`ALTER TABLE gym.caja ADD COLUMN IF NOT EXISTS nota_cierre varchar(300);`);
    console.log('✅ caja OK');

    // 5. traslados (usando gen_random_uuid en vez de uuid-ossp)
    await sql.unsafe(`
      CREATE TABLE IF NOT EXISTS gym.traslado_inventario (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
        sucursal_origen_id uuid NOT NULL REFERENCES gym.sucursal(id),
        sucursal_destino_id uuid NOT NULL REFERENCES gym.sucursal(id),
        estado varchar(20) NOT NULL DEFAULT 'CREADO',
        creado_por uuid NOT NULL REFERENCES gym.usuario(id),
        creado_at timestamptz NOT NULL DEFAULT now(),
        recibido_por uuid REFERENCES gym.usuario(id),
        recibido_at timestamptz
      );
    `);
    await sql.unsafe(`
      CREATE TABLE IF NOT EXISTS gym.traslado_inventario_det (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        traslado_id uuid NOT NULL REFERENCES gym.traslado_inventario(id) ON DELETE CASCADE,
        producto_id uuid NOT NULL REFERENCES gym.producto(id),
        cantidad numeric(12,2) NOT NULL
      );
    `);
    console.log('✅ Traslados OK');

    // 6. KPI
    await sql.unsafe(`
      CREATE TABLE IF NOT EXISTS gym.kpi_diario_sucursal (
        empresa_id uuid NOT NULL REFERENCES gym.empresa(id),
        sucursal_id uuid NOT NULL REFERENCES gym.sucursal(id),
        fecha date NOT NULL,
        total_ventas_centavos bigint NOT NULL DEFAULT 0,
        total_pagos_centavos bigint NOT NULL DEFAULT 0,
        asistencias int NOT NULL DEFAULT 0,
        ventas_count int NOT NULL DEFAULT 0,
        actualizado_at timestamptz NOT NULL DEFAULT now(),
        PRIMARY KEY(empresa_id, sucursal_id, fecha)
      );
    `);
    console.log('✅ KPI OK');

    // 7. Indices
    await sql.unsafe(`CREATE INDEX IF NOT EXISTS idx_sucursal_empresa ON gym.sucursal(empresa_id);`);
    await sql.unsafe(`CREATE INDEX IF NOT EXISTS idx_cliente_empresa ON gym.cliente(empresa_id);`);
    await sql.unsafe(`CREATE INDEX IF NOT EXISTS idx_plan_empresa ON gym.plan_membresia(empresa_id);`);
    await sql.unsafe(`CREATE INDEX IF NOT EXISTS idx_asistencia_sucursal_fecha ON gym.asistencia(sucursal_id, fecha_hora DESC);`);
    await sql.unsafe(`CREATE INDEX IF NOT EXISTS idx_caja_sucursal_estado ON gym.caja(sucursal_id, estado);`);
    await sql.unsafe(`CREATE INDEX IF NOT EXISTS idx_pago_caja_fecha ON gym.pago(caja_id, creado_at DESC);`);
    await sql.unsafe(`CREATE INDEX IF NOT EXISTS idx_venta_caja_fecha ON gym.venta(caja_id, creado_at DESC);`);
    await sql.unsafe(`CREATE INDEX IF NOT EXISTS idx_venta_sucursal_fecha ON gym.venta(sucursal_id, creado_at DESC);`);
    await sql.unsafe(`CREATE INDEX IF NOT EXISTS idx_mov_inv_sucursal_fecha ON gym.movimiento_inventario(sucursal_id, creado_at DESC);`);
    await sql.unsafe(`CREATE INDEX IF NOT EXISTS idx_cambio_empresa_seq ON gym.cambio_log(empresa_id, seq);`);
    console.log('✅ Índices OK');

    // 8. Caja unica
    await sql.unsafe(`CREATE UNIQUE INDEX IF NOT EXISTS uq_caja_abierta_unica ON gym.caja(empresa_id, sucursal_id, usuario_id) WHERE estado = 'ABIERTA';`);
    console.log('✅ Constraint caja OK');

    // 9. Listar tablas
    const tables = await sql`SELECT table_name FROM information_schema.tables WHERE table_schema='gym' ORDER BY table_name`;
    console.log(`\n📋 ${tables.length} tablas en gym:`);
    tables.forEach(t => console.log(`   - ${t.table_name}`));
    console.log('\n✅ BASE DE DATOS 100% LISTA');

  } catch (e) {
    console.error('❌', e.message);
  } finally {
    await sql.end();
  }
}
fix();
