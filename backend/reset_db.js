const { Client } = require('pg');

async function resetDb() {
    process.env.PGPASSWORD = "92li!ra$Gu2";
    console.log('Connecting to reset DB...');

    // Use session mode for dropping schemas if possible, or just standard connection
    const client = new Client({
        connectionString: "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-1-us-east-2.pooler.supabase.com:5432/postgres",
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        console.log('Connected.');

        console.log('Dropping schema gym cascade...');
        await client.query('DROP SCHEMA IF EXISTS gym CASCADE');

        console.log('Creating schema gym...');
        await client.query('CREATE SCHEMA gym');

        console.log('Reset complete.');
    } catch (e) {
        console.log('ERROR:', e.message);
    } finally {
        await client.end();
    }
}

resetDb();
