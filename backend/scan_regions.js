const { Client } = require('pg');

async function run() {
    const regions = ['us-west-2', 'sa-east-1', 'us-east-1', 'eu-west-1'];
    const user = 'postgres.ddmeodlpdxgmadduwdas';
    const pass = '92li!ra$Gu2';
    const db = 'postgres';

    for (const region of regions) {
        const host = `aws-0-${region}.pooler.supabase.com`;
        console.log(`Trying ${region} (${host})...`);
        const client = new Client({
            host,
            port: 5432,
            user,
            password: pass,
            database: db,
            ssl: { rejectUnauthorized: false },
            connectionTimeoutMillis: 5000
        });

        try {
            await client.connect();
            console.log(`SUCCESS in ${region}!`);
            await client.end();
            return;
        } catch (e) {
            console.log(`Failed in ${region}: ${e.message}`);
        } finally {
            await client.end().catch(() => { });
        }
    }
}

run();
