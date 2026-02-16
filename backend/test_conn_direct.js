const { Client } = require('pg');

const config = {
    connectionString: "postgresql://postgres:92li!ra$Gu2@db.ddmeodlpdxgmadduwdas.supabase.co:5432/postgres?sslmode=require",
};

async function test() {
    const client = new Client(config);
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
