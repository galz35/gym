const { Client } = require('pg');
const connectionString = "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-1-us-east-2.pooler.supabase.com:5432/postgres?sslmode=no-verify";

async function run() {
    const client = new Client({ connectionString, ssl: { rejectUnauthorized: false } });
    try {
        await client.connect();
        const empresa = await client.query('SELECT id FROM gym.empresa LIMIT 1');
        const user = await client.query('SELECT email FROM gym.usuario LIMIT 1');
        console.log('--- CREDENCIALES ---');
        console.log('Empresa ID:', empresa.rows[0].id);
        console.log('Email:', user.rows[0].email);
        console.log('Password: admin123');
        console.log('--------------------');
    } finally {
        await client.end();
    }
}
run();
