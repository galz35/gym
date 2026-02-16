const { Client } = require('pg');

async function run() {
    const client = new Client({
        host: 'aws-0-us-west-2.pooler.supabase.com',
        port: 5432,
        user: 'postgres.ddmeodlpdxgmadduwdas',
        password: '92li!ra$Gu2',
        database: 'postgres',
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('Connecting...');
        await client.connect();
        console.log('Connected!');
        const res = await client.query('SELECT current_user, current_database()');
        console.log(res.rows[0]);
    } catch (e) {
        console.error('FAILED TO CONNECT');
        console.error(e);
    } finally {
        await client.end().catch(() => { });
    }
}

run();
