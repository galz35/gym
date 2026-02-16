const { Client } = require('pg');

async function test() {
    console.log('Trying pooler: aws-0-us-west-1 ...');
    // Region: us-west-1?
    try {
        const client = new Client({
            connectionString: "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-0-us-west-1.pooler.supabase.com:6543/postgres",
            ssl: { rejectUnauthorized: false }
        });
        await client.connect();
        console.log('SUCCESS: aws-0-us-west-1');
        await client.end();
        return;
    } catch (e) { console.log('FAIL:', e.message); }

    console.log('Trying pooler: aws-0-eu-west-1 ...');
    try {
        const client = new Client({
            connectionString: "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-0-eu-west-1.pooler.supabase.com:6543/postgres",
            ssl: { rejectUnauthorized: false }
        });
        await client.connect();
        console.log('SUCCESS: aws-0-eu-west-1');
        await client.end();
        return;
    } catch (e) { console.log('FAIL:', e.message); }

    // Try aws-0-ap-northeast-1 ?
    console.log('Trying pooler: aws-0-ap-northeast-1 ...');
    try {
        const client = new Client({
            connectionString: "postgresql://postgres.ayyotvvjcwdoocdcouao:92li!ra$Gu2@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres",
            ssl: { rejectUnauthorized: false }
        });
        await client.connect();
        console.log('SUCCESS: aws-0-ap-northeast-1');
        await client.end();
        return;
    } catch (e) { console.log('FAIL:', e.message); }
}

test();
