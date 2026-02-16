const { Client } = require('pg');

async function test() {
    console.log('Connecting to AWS-0-US-EAST-1 with USERNAME postgres.ayyotvvjcwdoocdcouao ...');
    // Important: if direct connection, use only 'postgres'. But usually requires password.
    // If pooler, requires 'postgres.projectref'.
    // BUT the SSL mode is also critical.

    // Attempt 1: Direct connection, no pooler, standard port 5432, standard user 'postgres'
    console.log('--- Attempt 1: Direct, user [postgres], port 5432, db.ayyotvvjcwdoocdcouao.supabase.co ---');
    try {
        const client = new Client({
            connectionString: "postgresql://postgres:92li!ra$Gu2@db.ayyotvvjcwdoocdcouao.supabase.co:5432/postgres",
            ssl: { rejectUnauthorized: false }
        });
        await client.connect();
        console.log('SUCCESS: Direct connection!');
        await client.end();
        return;
    } catch (e) { console.log('FAIL 1:', e.message); }

    // Attempt 2: Pooler connection, port 6543, user [postgres.projectref], aws-0-us-east-1
    console.log('--- Attempt 2: Pooler, user [postgres.pref], port 6543, aws-0-us-east-1 ---');
    try {
        const client = new Client({
            connectionString: "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-0-us-east-1.pooler.supabase.com:6543/postgres",
            ssl: { rejectUnauthorized: false }
        });
        await client.connect();
        console.log('SUCCESS: Pooler connection!');
        await client.end();
        return;
    } catch (e) { console.log('FAIL 2:', e.message); }

    // Attempt 3: Maybe user IS in east-2? aws-0-us-east-2
    console.log('--- Attempt 3: Pooler, user [postgres.pref], port 6543, aws-0-us-east-2 ---');
    try {
        const client = new Client({
            connectionString: "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-0-us-east-2.pooler.supabase.com:6543/postgres",
            ssl: { rejectUnauthorized: false }
        });
        await client.connect();
        console.log('SUCCESS: Pooler connection east-2!');
        await client.end();
        return;
    } catch (e) { console.log('FAIL 3:', e.message); }
}

test();
