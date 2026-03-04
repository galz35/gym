import postgres from 'postgres';
import * as dotenv from 'dotenv';
import { readFileSync } from 'fs';
import { join } from 'path';

dotenv.config();

function cleanUrl(url: string) {
    // Remove query params like ?schema=... which are for Prisma
    return url.split('?')[0];
}

async function run() {
    const originalUrl = process.env.DATABASE_URL;
    if (!originalUrl) {
        console.error('DATABASE_URL not found in .env');
        return;
    }

    const cleanedUrl = cleanUrl(originalUrl);
    console.log('Connecting to (cleaned):', cleanedUrl);

    // Connect to the provided DB
    const sqlInit = postgres(cleanedUrl);

    let useDb = 'btvoley'; // Fallback to current DB if CREATE DATABASE fails

    try {
        console.log('Attempting to create database "gy"...');
        // CREATE DATABASE cannot be run inside a transaction
        await sqlInit.unsafe('CREATE DATABASE gy');
        console.log('Database "gy" created.');
        useDb = 'gy';
    } catch (e: any) {
        if (e.message.includes('already exists')) {
            console.log('Database "gy" already exists.');
            useDb = 'gy';
        } else {
            console.warn('Could not create database "gy":', e.message);
            console.log('Will proceed using current database:', useDb);
        }
    } finally {
        await sqlInit.end();
    }

    // Connect to the target database
    const targetUrl = cleanedUrl.replace(/\/([^\/]+)$/, `/${useDb}`);
    console.log('Connecting to target database:', targetUrl);
    const sql = postgres(targetUrl);

    try {
        console.log('Creating schema "gym"...');
        await sql`CREATE SCHEMA IF NOT EXISTS gym`;

        // We will execute the SQL as several blocks to avoid massive single-string issues
        // and handle potential errors in specific parts.

        const specPath = join(__dirname, '../../Gym_Supabase_NestJS_Flutter_Spec.txt');
        const specContent = readFileSync(specPath, 'utf-8');

        const sqlStartMark = '-- 4.1 Extensiones';
        const startIdx = specContent.indexOf(sqlStartMark);
        const endIdx = specContent.indexOf('5) Lógica crítica');

        if (startIdx === -1) {
            throw new Error('Could not find SQL section in spec file');
        }

        let schemaSql = specContent.substring(startIdx, endIdx);

        // Remove the headers "====================" if they appear in the middle
        schemaSql = schemaSql.replace(/={10,}/g, '');

        console.log('Executing schema SQL...');
        // We run it as one unsafe block because it contains multiple statements,
        // but we need to ensure search_path is correct.
        await sql.unsafe(`
            SET search_path TO gym, public;
            ${schemaSql}
        `);

        console.log('Schema created successfully.');

        console.log('Seeding roles into gym.rol...');
        await sql`
            INSERT INTO gym.rol(nombre) VALUES 
            ('ADMIN'), ('CAJA'), ('RECEPCION'), ('INVENTARIO') 
            ON CONFLICT (nombre) DO NOTHING
        `;

        console.log('Database setup complete.');

    } catch (e: any) {
        console.error('Error setting up database:', e);
    } finally {
        await sql.end();
    }
}

run();
