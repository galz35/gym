const { Client } = require('pg');

const connectionString = "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-1-us-east-2.pooler.supabase.com:5432/postgres?sslmode=no-verify";

async function fix() {
    const client = new Client({ connectionString, ssl: { rejectUnauthorized: false } });
    try {
        await client.connect();
        console.log('Connected.');
        console.log('Dropping conflicting index...');
        await client.query('DROP INDEX IF EXISTS gym.uq_caja_abierta_unica');
        console.log('Index dropped. Now Prisma push should work.');
    } catch (e) {
        console.error(e);
    } finally {
        await client.end();
    }
}

fix();
