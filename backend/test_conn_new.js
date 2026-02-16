const { Client } = require('pg');

// User provided: aws-1-us-east-2.pooler.supabase.com
// Usually the region is aws-0-us-east-1 for free tier, or aws-0-sa-east-1 etc.
// But aws-0-us-west-1.pooler.supabase.com is also possible.
// Based on the user input, they said: aws-1-us-east-2.pooler.supabase.com:6543
// Let's try that EXACT host.

const connectionStringUser = "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-0-us-east-1.pooler.supabase.com:6543/postgres?sslmode=disable";

// Fix: "self-signed certificate in certificate chain" means we need rejectUnauthorized: false in code,
// OR valid certs. For test script we use rejectUnauthorized: false.

const client = new Client({
    connectionString: connectionStringUser,
    ssl: { rejectUnauthorized: false }
});

async function test() {
    console.log('Connecting...');
    try {
        await client.connect();
        console.log('Successfully connected!');
        const res = await client.query('SELECT NOW()');
        console.log('Time:', res.rows[0].now);
    } catch (err) {
        console.log('--- ERROR ---');
        console.log(err.message);
        if (err.parent) console.log(err.parent);
        console.log('--- END ERROR ---');
    } finally {
        await client.end();
    }
}

test();
