const { Client } = require('pg');
const bcrypt = require('bcrypt');

const connectionString = "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-1-us-east-2.pooler.supabase.com:5432/postgres?sslmode=no-verify";

async function run() {
    const client = new Client({
        connectionString,
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        console.log('Connected to database.');

        // 1. Check for Empresa
        const empresaRes = await client.query('SELECT id, nombre FROM gym.empresa LIMIT 1');
        let empresaId;
        if (empresaRes.rows.length === 0) {
            console.log('No empresa found. Creating default...');
            const newEmpresa = await client.query("INSERT INTO gym.empresa (nombre) VALUES ('GymPro Central') RETURNING id");
            empresaId = newEmpresa.rows[0].id;
        } else {
            empresaId = empresaRes.rows[0].id;
            console.log(`Found empresa: ${empresaRes.rows[0].nombre} (${empresaId})`);
        }

        // 2. Check for Sucursal
        const sucursalRes = await client.query('SELECT id, nombre FROM gym.sucursal WHERE empresa_id = $1 LIMIT 1', [empresaId]);
        let sucursalId;
        if (sucursalRes.rows.length === 0) {
            console.log('No sucursal found. Creating default...');
            const newSucursal = await client.query("INSERT INTO gym.sucursal (empresa_id, nombre, direccion) VALUES ($1, 'Sucursal Matriz', 'Ciudad Central') RETURNING id", [empresaId]);
            sucursalId = newSucursal.rows[0].id;
        } else {
            sucursalId = sucursalRes.rows[0].id;
            console.log(`Found sucursal: ${sucursalRes.rows[0].nombre}`);
        }

        // 3. Check for Admin User
        const userRes = await client.query('SELECT id, email FROM gym.usuario WHERE empresa_id = $1 LIMIT 1', [empresaId]);
        if (userRes.rows.length === 0) {
            console.log('No user found. Creating admin...');
            const hash = await bcrypt.hash('admin123', 10);
            const newUser = await client.query(
                "INSERT INTO gym.usuario (empresa_id, email, nombre, hash, estado) VALUES ($1, $2, $3, $4, 'ACTIVO') RETURNING id",
                [empresaId, 'admin@gympro.com', 'Administrador', hash]
            );
            const userId = newUser.rows[0].id;

            // Assign ADMIN role
            const roleRes = await client.query("SELECT id FROM gym.rol WHERE nombre = 'ADMIN'");
            if (roleRes.rows.length > 0) {
                await client.query("INSERT INTO gym.usuario_rol (usuario_id, rol_id) VALUES ($1, $2)", [userId, roleRes.rows[0].id]);
            }

            // Assign to Sucursal
            await client.query("INSERT INTO gym.usuario_sucursal (usuario_id, sucursal_id) VALUES ($1, $2)", [userId, sucursalId]);

            console.log('Admin user created: admin@gympro.com / admin123');
        } else {
            console.log(`Found existing user: ${userRes.rows[0].email}`);
        }

        console.log('\n--- CREDENCIALES DE ACCESO ---');
        console.log(`EMPRESA ID: ${empresaId}`);
        console.log('EMAIL: admin@gympro.com (o el que ya existiera)');
        console.log('PASSWORD: admin123 (si se acaba de crear)');
        console.log('------------------------------');

    } catch (e) {
        console.error('ERROR:', e.message);
    } finally {
        await client.end();
    }
}

run();
