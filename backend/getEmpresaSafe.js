const fs = require('fs');
const postgres = require('postgres');
const sql = postgres('postgresql://alacaja:TuClaveFuerte@190.56.16.85:5432/gym_db');
sql`SELECT id FROM gym.empresa LIMIT 1`.then(r => {
    fs.writeFileSync('id.json', JSON.stringify({id: r[0].id}));
    sql.end();
}).catch(e => {
    sql.end();
});
