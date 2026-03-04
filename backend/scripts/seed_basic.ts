import postgres from 'postgres';
import * as dotenv from 'dotenv';
import * as bcrypt from 'bcrypt';

dotenv.config();

async function seed() {
    const sql = postgres(process.env.DATABASE_URL!);

    try {
        console.log('Seeding initial data...');

        // 1. Create Empresa
        const [empresa] = await sql`
            INSERT INTO gym.empresa (nombre, estado)
            VALUES ('Gym Central', 'ACTIVO')
            RETURNING id
        `;
        console.log('Empresa created:', empresa.id);

        // 2. Create Sucursal
        const [sucursal] = await sql`
            INSERT INTO gym.sucursal (empresa_id, nombre, direccion)
            VALUES (${empresa.id}, 'Sucursal Principal', 'Av. Siempre Viva 123')
            RETURNING id
        `;
        console.log('Sucursal created:', sucursal.id);

        // 3. Create Admin User
        const email = 'admin@gym.com';
        const password = 'admin'; // You should change this!
        const hash = await bcrypt.hash(password, 10);

        const [usuario] = await sql`
            INSERT INTO gym.usuario (empresa_id, email, nombre, hash, estado, token_version)
            VALUES (${empresa.id}, ${email}, 'Administrador', ${hash}, 'ACTIVO', 1)
            RETURNING id
        `;
        console.log('User created:', usuario.id);

        // 4. Assign Roles
        const [rolAdmin] = await sql`SELECT id FROM gym.rol WHERE nombre = 'ADMIN'`;
        await sql`
            INSERT INTO gym.usuario_rol (usuario_id, rol_id)
            VALUES (${usuario.id}, ${rolAdmin.id})
        `;
        console.log('Role ADMIN assigned.');

        // 5. Assign Sucursal
        await sql`
            INSERT INTO gym.usuario_sucursal (usuario_id, sucursal_id)
            VALUES (${usuario.id}, ${sucursal.id})
        `;
        console.log('Sucursal assigned to user.');

        console.log('Seeding complete.');
        console.log('Login credentials:');
        console.log(`Email: ${email}`);
        console.log(`Password: ${password}`);
        console.log(`Empresa ID: ${empresa.id}`);

    } catch (e) {
        console.error('Error seeding data:', e);
    } finally {
        await sql.end();
    }
}

seed();
