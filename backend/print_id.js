const { Client } = require('pg');
const connectionString = "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-1-us-east-2.pooler.supabase.com:5432/postgres?sslmode=no-verify";

async function run() {
    const client = new Client({ connectionString, ssl: { rejectUnauthorized: false } });
    try {
        await client.connect();
        const res = await client.query('SELECT id FROM gym.empresa LIMIT 1');
        console.log('START_ID');
        console.log(res.rows[0].id);
        console.log('END_ID');
    } finally {
        await client.end();
    }
}
run();
