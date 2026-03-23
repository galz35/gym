const postgres = require('postgres');
require('dotenv').config();

async function test() {
  const url = process.env.DATABASE_URL || 'postgresql://alacaja:TuClaveFuerte@127.0.0.1:5432/gym_db';
  console.log('Testing connection to:', url);
  try {
    const sql = postgres(url, { max: 1, idle_timeout: 3 });
    const version = await sql`SELECT version()`;
    console.log('PostgreSQL version:', version[0].version);
    
    const tables = await sql`SELECT table_name FROM information_schema.tables WHERE table_schema = 'gym'`;
    if (tables.length === 0) {
      console.log('No tables found in "gym" schema. Are you sure the schema is created and initialized?');
    } else {
      console.log('Tables in gym schema:', tables.map(t => t.table_name).join(', '));
    }
    
    // Test if we have clients
    try {
      const clientes = await sql`SELECT count(*) FROM gym.cliente`;
      console.log('Number of clients in DB:', clientes[0].count);
    } catch (e) {
      console.log('Could not query gym.cliente table:', e.message);
    }
    
    await sql.end();
  } catch (err) {
    console.error('Error connecting to DB:', err.message);
  }
}
test();
