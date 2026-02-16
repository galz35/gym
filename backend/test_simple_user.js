const { Client } = require('pg');

async function run() {
    const client = new Client({
        host: 'aws-0-us-west-2.pooler.supabase.com',
        port: 5432,
        user: 'postgres',
        password: '92li!ra$Gu2',
        database: 'postgres',
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('Connecting as postgres...');
        await client.connect();
        console.log('Connected!');
    } catch (e) {
        console.error('FAILED');
        console.error(e.message);
    } finally {
        await client.end().catch(() => { });
    }
}

run();
