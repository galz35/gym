const { Client } = require('pg');

const config = {
    host: "aws-0-us-west-2.pooler.supabase.com",
    port: 5432,
    user: "postgres.ddmeodlpdxgmadduwdas",
    password: "92li!ra$Gu2",
    database: "postgres",
    ssl: { rejectUnauthorized: false }
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
        console.log('Message:', err.message);
        console.log('Code:', err.code);
        console.log('Detail:', err.detail);
        console.log('--- END ERROR ---');
    } finally {
        await client.end();
    }
}

test();
