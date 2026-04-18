const postgres = require('postgres');
const sql = postgres('postgresql://alacaja:TuClaveFuerte@190.56.16.85:5432/gym_db');
sql`SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'gym'`.then(r => {
    console.log(JSON.stringify(r.map(x => x.routine_name), null, 2));
    process.exit(0);
}).catch(e => {
    console.error(e);
    process.exit(1);
});
