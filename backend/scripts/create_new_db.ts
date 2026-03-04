import postgres from 'postgres';
import * as dotenv from 'dotenv';

dotenv.config();

function cleanUrl(url: string) {
    return url.split('?')[0];
}

async function run() {
    const originalUrl = process.env.DATABASE_URL;
    if (!originalUrl) {
        console.error('DATABASE_URL not found in .env');
        return;
    }

    const cleanedUrl = cleanUrl(originalUrl);
    // Connect to whatever database is current (likely 'gy' or 'btvoley') to create the new one
    const sqlInit = postgres(cleanedUrl);

    const newDbName = 'gym_db';

    try {
        console.log(`Attempting to create a new database named "${newDbName}"...`);
        await sqlInit.unsafe(`CREATE DATABASE ${newDbName}`);
        console.log(`Database "${newDbName}" created successfully.`);
    } catch (e: any) {
        if (e.message.includes('already exists')) {
            console.log(`Database "${newDbName}" already exists.`);
        } else {
            console.error(`Error creating database "${newDbName}":`, e.message);
        }
    } finally {
        await sqlInit.end();
    }

    // Now connect to the NEW database to create the table
    const targetUrl = cleanedUrl.replace(/\/([^\/]+)$/, `/${newDbName}`);
    console.log(`Connecting to new database: ${targetUrl}`);
    const sql = postgres(targetUrl);

    try {
        console.log('Creating a new table "test_connection"...');
        await sql`
            CREATE TABLE IF NOT EXISTS public.test_connection (
                id serial PRIMARY KEY,
                description text NOT NULL,
                created_at timestamptz DEFAULT now()
            )
        `;

        await sql`
            INSERT INTO public.test_connection (description) 
            VALUES ('Initial record for the new database')
        `;

        console.log('Table created and record inserted.');

    } catch (e: any) {
        console.error('Error creating table:', e);
    } finally {
        await sql.end();
    }
}

run();
