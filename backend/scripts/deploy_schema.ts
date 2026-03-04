import postgres from 'postgres';
import * as dotenv from 'dotenv';
import { readFileSync } from 'fs';
import { join } from 'path';

dotenv.config();

async function run() {
    const dbUrl = process.env.DATABASE_URL;
    if (!dbUrl) {
        console.error('DATABASE_URL not found in .env');
        return;
    }

    console.log('Connecting to:', dbUrl.split('@')[1] || 'database'); // Log only host for privacy
    const sql = postgres(dbUrl);

    try {
        console.log('Creating schema "gym"...');
        await sql`CREATE SCHEMA IF NOT EXISTS gym`;

        const specPath = join(__dirname, '../../Gym_Supabase_NestJS_Flutter_Spec.txt');
        const specContent = readFileSync(specPath, 'utf-8');

        const sqlStartMark = '-- 4.1 Extensiones';
        const startIdx = specContent.indexOf(sqlStartMark);
        const endIdx = specContent.indexOf('5) Lógica crítica');

        if (startIdx === -1) {
            throw new Error('Could not find SQL section in spec file');
        }

        let schemaSql = specContent.substring(startIdx, endIdx);
        schemaSql = schemaSql.replace(/={10,}/g, ''); // Clean formatting marks

        console.log('Deploying full schema to "gym" schema...');
        await sql.unsafe(`
            SET search_path TO gym, public;
            ${schemaSql}
        `);

        console.log('Schema deployed successfully.');

        console.log('Seeding initial roles...');
        await sql`
            INSERT INTO gym.rol(nombre) VALUES 
            ('ADMIN'), ('CAJA'), ('RECEPCION'), ('INVENTARIO') 
            ON CONFLICT (nombre) DO NOTHING
        `;

        console.log('Deployment complete.');

    } catch (e: any) {
        console.error('Error during schema deployment:', e);
    } finally {
        await sql.end();
    }
}

run();
