const { Client } = require('pg');

async function test() {
    process.env.PGPASSWORD = "92li!ra$Gu2";

    // User URL: https://supabase.com/dashboard/project/ayyotvvjcwdoocdcouao

    console.log('--- Attempt 4: aws-1-us-east-2 (User mentioned this) ---');
    try {
        const client = new Client({
            // User put aws-1-us-east-2 in the text block.
            // But they also put pgBouncer=true.
            // Maybe it is simply aws-1-us-east-2.
            // Let's retry it just in case SSL was the issue last time.
            connectionString: "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-1-us-east-2.pooler.supabase.com:6543/postgres",
            ssl: { rejectUnauthorized: false }
        });
        await client.connect();
        console.log('SUCCESS: aws-1-us-east-2');
        await client.end();
    } catch (e) { console.log('FAIL 4:', e.message); }
}

test();
