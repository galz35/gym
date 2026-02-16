const { Client } = require('pg');

async function test() {
    console.log('Connecting to DIRECT URL (db.ayyotvvjcwdoocdcouao.supabase.co)...');
    const client = new Client({
        connectionString: "postgresql://postgres:92li!ra$Gu2@db.ayyotvvjcwdoocdcouao.supabase.co:5432/postgres",
        ssl: { rejectUnauthorized: false },
        connectionTimeoutMillis: 5000
    });
    try {
        await client.connect();
        console.log('SUCCESS!');
        await client.end();
    } catch (e) {
        console.log('FAIL:', e.message);
    }
}

test();
