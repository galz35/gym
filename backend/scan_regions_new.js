const { Client } = require('pg');

// Trying to find region from DNS 
// User project: ayyotvvjcwdoocdcouao

const projects = [
    // Standard regions
    'aws-0-us-east-1.pooler.supabase.com',
    'aws-0-us-west-1.pooler.supabase.com',
    'aws-0-sa-east-1.pooler.supabase.com',
    'aws-0-eu-west-1.pooler.supabase.com',
    'aws-0-ap-southeast-1.pooler.supabase.com',
    // User mentioned: aws-1-us-east-2
    'aws-1-us-east-2.pooler.supabase.com'
];

async function tryConnect(host) {
    const cs = `postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@${host}:6543/postgres?sslmode=require`;
    console.log('Trying:', host);
    const client = new Client({
        connectionString: cs,
        ssl: { rejectUnauthorized: false },
        connectionTimeoutMillis: 5000
    });

    try {
        await client.connect();
        console.log('SUCCESS:', host);
        await client.end();
        return true;
    } catch (e) {
        console.log('FAIL:', host, e.message);
        return false;
    }
}

async function run() {
    for (const p of projects) {
        if (await tryConnect(p)) break;
    }
}

run();
