const postgres = require('postgres');
const sql = postgres('postgresql://alacaja:TuClaveFuerte@190.56.16.85:5432/gym_db');
sql`SELECT column_name FROM information_schema.columns WHERE table_schema = 'gym' AND table_name = 'membresia_cliente'`.then(r => {
    console.log(JSON.stringify(r.map(x => x.column_name), null, 2));
    process.exit(0);
}).catch(e => {
    console.error(e);
    process.exit(1);
});
