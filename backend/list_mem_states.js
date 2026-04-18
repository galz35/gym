const postgres = require('postgres');
const sql = postgres('postgresql://alacaja:TuClaveFuerte@190.56.16.85:5432/gym_db');
sql`SELECT id, estado FROM gym.membresia_cliente ORDER BY creado_at DESC LIMIT 5`.then(r => {
    console.log(r);
    process.exit(0);
}).catch(e => {
    console.error(e);
    process.exit(1);
});
