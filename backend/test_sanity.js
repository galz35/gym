const { Client } = require('pg');

async function test() {
    console.log('Connecting to DIRECT URL using correct user...');
    // When using direct connection, user is simple 'postgres', but maybe the project ref is wrong?
    // User URL: https://supabase.com/dashboard/project/ayyotvvjcwdoocdcouao
    // Connection string: postgresql://postgres:[YOUR-PASSWORD]@db.ayyotvvjcwdoocdcouao.supabase.co:5432/postgres
    // Wait, the nslookup succeeded above! It returned an IPv6 address.
    // Node default behavior in some envs might prefer IPv4 or have issues with IPv6.

    // Let's force IPv4 if possible? Or maybe the DB only has IPv6 from some ISPs?
    // Supabase usually has IPv4 support.

    // BUT the error from node was ENOTFOUND, which usually means DNS failed.
    // Wait, nslookup succeeded. Node failed. That's weird.
    // Ah, nslookup output showed Address: 2600:1f16:1cd0:3339:3e70:5713:c166a:924a
    // It did NOT show an IPv4 address.

    // If Supabase project is on Free tier or certain regions, it might be IPv6 only for direct connection?
    // Or maybe I just need to use the pooler.

    // Pooler failures: "Tenant or user not found"
    // This usually means:
    // 1. The project ref (ayyotvvjcwdoocdcouao) is correct.
    // 2. The region used in hostname (aws-0-us-east-1 etc) is WRONG.
    // 3. The username format (postgres.projectref) is correct but project doesn't exist in that region.

    // Let's guess the region from the project ref if possible? No easy way.
    // But the user said: aws-1-us-east-2.pooler.supabase.com
    // Let's try that AGAIN but with correct username format.

    const host = 'aws-0-us-east-1.pooler.supabase.com'; // Trying standard again
    console.log('Trying pooler again with user and pass...');

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
