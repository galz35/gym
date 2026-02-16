const { Client } = require('pg');

const config = {
    // User provided URL parts:
    // host: aws-1-us-east-2.pooler.supabase.com (Wait, user said this?)
    // but the URL in the text block was: postgresql://postgres.ayyotvvjcwdoocdcouao:[YOUR-PASSWORD]@aws-1-us-east-2.pooler.supabase.com:6543/postgres?pgbouncer=true
    // Let's try THAT exact host again with correct SSL.
    connectionString: "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-0-us-east-1.pooler.supabase.com:6543/postgres?sslmode=require",
    ssl: { rejectUnauthorized: false }
};

async function test() {
    console.log('Connecting to AWS-0-US-EAST-1...');
    const client = new Client({
        connectionString: "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-0-us-east-1.pooler.supabase.com:6543/postgres",
        ssl: { rejectUnauthorized: false }
    });
    try {
        await client.connect();
        console.log('SUCCESS!');
        await client.end();
    } catch (e) {
        console.log('FAIL:', e.message);
    }
}

test();
