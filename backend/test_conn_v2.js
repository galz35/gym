const { Client } = require('pg');

const connectionString = "postgresql://postgres.ddmeodlpdxgmadduwdas:92li!ra$Gu2@aws-0-us-west-2.pooler.supabase.com:5432/postgres?sslmode=no-verify";

async function test() {
    const client = new Client({
        connectionString,
        ssl: { rejectUnauthorized: false }
    });
    try {
        await client.connect();
        console.log('Successfully connected!');
        const res = await client.query('SELECT NOW()');
        console.log('Time:', res.rows[0].now);
    } catch (err) {
        console.log('--- ERROR ---');
        console.log(err);
        console.log('--- END ERROR ---');
    } finally {
        if (client) await client.end();
    }
}

test();
