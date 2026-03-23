const postgres = require('postgres');
const bcrypt = require('bcrypt');

const url = 'postgresql://alacaja:TuClaveFuerte@190.56.16.85:5432/gym_db';
const sql = postgres(url, { max: 1 });

async function seed() {
  try {
    console.log('Conectando a la base de datos...');

    // 1. Roles
    console.log('── Creando roles...');
    await sql`INSERT INTO gym.rol(nombre) VALUES ('ADMIN') ON CONFLICT DO NOTHING`;
    await sql`INSERT INTO gym.rol(nombre) VALUES ('CAJA') ON CONFLICT DO NOTHING`;
    await sql`INSERT INTO gym.rol(nombre) VALUES ('RECEPCION') ON CONFLICT DO NOTHING`;
    await sql`INSERT INTO gym.rol(nombre) VALUES ('INVENTARIO') ON CONFLICT DO NOTHING`;
    console.log('   ✅ Roles creados');

    // 2. Empresa
    console.log('── Creando empresa...');
    const existEmpresa = await sql`SELECT id FROM gym.empresa LIMIT 1`;
    let empresaId;
    if (existEmpresa.length > 0) {
      empresaId = existEmpresa[0].id;
      console.log(`   ⚡ Empresa ya existe: ${empresaId}`);
    } else {
      const [empresa] = await sql`
        INSERT INTO gym.empresa (nombre, estado)
        VALUES ('Gym Central', 'ACTIVO')
        RETURNING id
      `;
      empresaId = empresa.id;
      console.log(`   ✅ Empresa creada: ${empresaId}`);
    }

    // 3. Sucursal
    console.log('── Creando sucursal...');
    const existSuc = await sql`SELECT id FROM gym.sucursal WHERE empresa_id = ${empresaId} LIMIT 1`;
    let sucursalId;
    if (existSuc.length > 0) {
      sucursalId = existSuc[0].id;
      console.log(`   ⚡ Sucursal ya existe: ${sucursalId}`);
    } else {
      const [sucursal] = await sql`
        INSERT INTO gym.sucursal (empresa_id, nombre, direccion)
        VALUES (${empresaId}, 'Sucursal Principal', 'Ciudad')
        RETURNING id
      `;
      sucursalId = sucursal.id;
      console.log(`   ✅ Sucursal creada: ${sucursalId}`);
    }

    // 4. Usuario Admin
    console.log('── Creando usuario admin...');
    const existUser = await sql`SELECT id FROM gym.usuario WHERE empresa_id = ${empresaId} AND email = 'admin@gym.com' LIMIT 1`;
    let userId;
    if (existUser.length > 0) {
      userId = existUser[0].id;
      console.log(`   ⚡ Usuario admin ya existe: ${userId}`);
    } else {
      const hash = await bcrypt.hash('admin', 10);
      const [usuario] = await sql`
        INSERT INTO gym.usuario (empresa_id, email, nombre, hash, estado, token_version)
        VALUES (${empresaId}, 'admin@gym.com', 'Administrador', ${hash}, 'ACTIVO', 1)
        RETURNING id
      `;
      userId = usuario.id;
      console.log(`   ✅ Usuario admin creado: ${userId}`);
    }

    // 5. Asignar rol ADMIN
    console.log('── Asignando rol ADMIN...');
    const [rolAdmin] = await sql`SELECT id FROM gym.rol WHERE nombre = 'ADMIN'`;
    await sql`INSERT INTO gym.usuario_rol (usuario_id, rol_id) VALUES (${userId}, ${rolAdmin.id}) ON CONFLICT DO NOTHING`;
    console.log('   ✅ Rol asignado');

    // 6. Asignar sucursal
    console.log('── Asignando sucursal...');
    await sql`INSERT INTO gym.usuario_sucursal (usuario_id, sucursal_id) VALUES (${userId}, ${sucursalId}) ON CONFLICT DO NOTHING`;
    console.log('   ✅ Sucursal asignada');

    // 7. Planes básicos
    console.log('── Creando planes de membresía...');
    const existPlanes = await sql`SELECT count(*) as c FROM gym.plan_membresia WHERE empresa_id = ${empresaId}`;
    if (parseInt(existPlanes[0].c) === 0) {
      await sql`INSERT INTO gym.plan_membresia (empresa_id, nombre, tipo, dias, precio_centavos) VALUES (${empresaId}, 'Día', 'DIAS', 1, 5000)`;
      await sql`INSERT INTO gym.plan_membresia (empresa_id, nombre, tipo, dias, precio_centavos) VALUES (${empresaId}, 'Semana', 'DIAS', 7, 25000)`;
      await sql`INSERT INTO gym.plan_membresia (empresa_id, nombre, tipo, dias, precio_centavos) VALUES (${empresaId}, 'Quincenal', 'DIAS', 15, 45000)`;
      await sql`INSERT INTO gym.plan_membresia (empresa_id, nombre, tipo, dias, precio_centavos) VALUES (${empresaId}, 'Mes', 'DIAS', 30, 80000)`;
      console.log('   ✅ 4 planes creados (Día Q50, Semana Q250, Quincenal Q450, Mes Q800)');
    } else {
      console.log(`   ⚡ Ya existen ${existPlanes[0].c} planes`);
    }

    console.log('\n═══════════════════════════════════════════');
    console.log('   ✅ SEED COMPLETADO');
    console.log('═══════════════════════════════════════════');
    console.log(`   Empresa ID:  ${empresaId}`);
    console.log(`   Sucursal ID: ${sucursalId}`);
    console.log(`   Usuario ID:  ${userId}`);
    console.log(`   Login: admin@gym.com / admin`);
    console.log('═══════════════════════════════════════════');

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await sql.end();
  }
}

seed();
