const { Client } = require('pg');

async function test() {
    process.env.PGPASSWORD = "92li!ra$Gu2";
    console.log('Testing direct/session port 5432 on pooler host...');

    // Try standard session port on pooler host?
    // Usually pooler host runs pgbouncer on 6543 (transaction) and maybe 5432 (session)?
    // Or maybe 5432 is just standard postgres if exposed?
    // Let's try port 5432 with pooler user format first.

    try {
        console.log('Trying: aws-1-us-east-2.pooler.supabase.com:5432 (user: postgres.ayyotvvjcwdoocdcouao)');
        const client = new Client({
            connectionString: "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-1-us-east-2.pooler.supabase.com:5432/postgres",
            ssl: { rejectUnauthorized: false },
            connectionTimeoutMillis: 5000
        });
        await client.connect();
        console.log('SUCCESS: 5432 works!');
        await client.end();
    } catch (e) { console.log('FAIL 5432:', e.message); }
}

test();
