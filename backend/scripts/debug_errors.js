const https = require('https');
const fs = require('fs');

const BASE = 'https://rhclaroni.com/apig';
let TOKEN = null;
let SUCURSAL_ID = null;

function req(method, path, body) {
  const url = new URL(BASE + path);
  return new Promise((resolve) => {
    const opts = {
      hostname: url.hostname, path: url.pathname + url.search, method,
      headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
      rejectUnauthorized: false,
    };
    if (TOKEN) opts.headers['Authorization'] = 'Bearer ' + TOKEN;
    if (SUCURSAL_ID) opts.headers['X-Sucursal-Id'] = SUCURSAL_ID;
    const r = https.request(opts, (res) => {
      let d = '';
      res.on('data', (c) => d += c);
      res.on('end', () => {
        try { resolve({ s: res.statusCode, d: JSON.parse(d) }); }
        catch { resolve({ s: res.statusCode, d }); }
      });
    });
    r.on('error', (e) => resolve({ s: 0, d: e.message }));
    if (body) r.write(JSON.stringify(body));
    r.end();
  });
}

async function main() {
  const out = [];
  const log = (msg) => { out.push(msg); };

  const l = await req('POST', '/auth/login', { email:'admin@gym.com', password:'admin' });
  TOKEN = l.d.accessToken;
  SUCURSAL_ID = l.d.user?.sucursales?.[0]?.id;
  log(`Login: ${l.s} | Sucursal: ${SUCURSAL_ID}`);

  // Crear cliente
  const nc = await req('POST', '/clientes', { nombre:'Test Debug', telefono:'12345' });
  log(`\nCrear Cliente: ${nc.s}`);
  log(JSON.stringify(nc.d, null, 2));

  // Reportes
  const rp = await req('GET', '/reportes/resumen-dia');
  log(`\nReportes: ${rp.s}`);
  log(JSON.stringify(rp.d, null, 2));

  // Guardar resultado en archivo
  fs.writeFileSync('debug_result.txt', out.join('\n'));
  console.log('Resultado guardado en debug_result.txt');
}
main();
