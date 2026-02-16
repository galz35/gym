const { Client } = require('pg');

async function test() {
    console.log('Using connection string provided by user in Dashboard screenshot...');
    // User dashboard possibly says:
    // User: postgres (if direct) OR postgres.ayyotvvjcwdoocdcouao (if pooler)
    // Host: aws-0-us-east-2.pooler.supabase.com (EAST-2 ??)

    // Let's try aws-0-us-east-2.pooler.supabase.com
    // Because user said: aws-1-us-east-2.pooler.supabase.com, maybe it was aws-0 ?

    const host = 'aws-0-us-east-2.pooler.supabase.com';
    console.log(`Trying ${host}...`);

    const client = new Client({
        connectionString: `postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@${host}:6543/postgres`,
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
