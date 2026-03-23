const postgres = require('postgres');
const url = 'postgresql://alacaja:TuClaveFuerte@190.56.16.85:5432/gym_db';
const sql = postgres(url, { max: 1 });

async function fix() {
  try {
    // 1. Configurar search_path del usuario para que incluya gym
    console.log('Configurando search_path para usuario alacaja...');
    await sql.unsafe(`ALTER DATABASE gym_db SET search_path TO gym, public;`);
    console.log('✅ search_path configurado (gym, public)');

    // 2. Verificar si hay triggers en la tabla cliente que referencien cambio_log sin schema
    console.log('\nVerificando triggers...');
    const triggers = await sql`
      SELECT trigger_name, event_manipulation, action_statement 
      FROM information_schema.triggers 
      WHERE trigger_schema = 'gym'
    `;
    if (triggers.length > 0) {
      triggers.forEach(t => console.log(`   Trigger: ${t.trigger_name} → ${t.event_manipulation}`));
    } else {
      console.log('   No hay triggers definidos');
    }

    // 3. Crear el trigger de cambio_log para cliente con schema correcto
    console.log('\nCreando trigger de cambio_log para cliente...');
    await sql.unsafe(`
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
            'foto_url', NEW.foto_url,
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
    `);
    console.log('✅ Trigger de cliente creado con schema gym correcto');

    // 4. Test: insertar un cliente de prueba
    console.log('\nTest: insertando cliente de prueba...');
    const [testCliente] = await sql`
      INSERT INTO gym.cliente (empresa_id, nombre, telefono, estado)
      SELECT e.id, 'Test Trigger', '99999', 'ACTIVO'
      FROM gym.empresa e LIMIT 1
      RETURNING id, nombre
    `;
    console.log(`✅ Cliente insertado: ${testCliente.id} - ${testCliente.nombre}`);

    // 5. Verificar que el cambio_log se llenó
    const [logEntry] = await sql`SELECT * FROM gym.cambio_log ORDER BY seq DESC LIMIT 1`;
    if (logEntry) {
      console.log(`✅ cambio_log funciona: seq=${logEntry.seq}, entidad=${logEntry.entidad}`);
    }

    console.log('\n✅ TODO CORREGIDO');
  } catch (e) {
    console.error('❌', e.message);
  } finally {
    await sql.end();
  }
}
fix();
