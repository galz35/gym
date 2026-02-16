const { Client } = require('pg');

async function test() {
    console.log('Connecting to AWS-0-EU-CENTRAL-1...');
    const client = new Client({
        connectionString: "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-0-eu-central-1.pooler.supabase.com:6543/postgres",
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
