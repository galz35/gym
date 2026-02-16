const { Client } = require('pg');

const hosts = [
    'aws-0-us-east-1.pooler.supabase.com',
    'aws-0-us-west-1.pooler.supabase.com',
    // Try other regions if needed, but start small
];

async function tryConnect(host) {
    console.log(`Trying ${host}...`);
    const client = new Client({
        connectionString: `postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@${host}:6543/postgres?sslmode=require`,
        // IMPORTANT: rejectUnauthorized: false is needed for self-signed certs which Supabase poolers might use depending on client config
        ssl: { rejectUnauthorized: false },
        connectionTimeoutMillis: 5000,
    });

    try {
        await client.connect();
        console.log(`SUCCESS connected to ${host}`);
        const res = await client.query('SELECT current_database()');
        console.log('DB:', res.rows[0]);
        await client.end();
        return true;
    } catch (e) {
        console.log(`FAIL ${host}: ${e.message}`);
        // console.log(e); // Debug full error if needed
        return false;
    }
}

async function run() {
    for (const h of hosts) {
        if (await tryConnect(h)) break;
    }
}

run();
