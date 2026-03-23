const http = require('https');

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
    const r = http.request(opts, (res) => {
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
  console.log('═══ TEST COMPLETO BACKEND GYM ═══\n');

  // 1. Health
  const h = await req('GET', '/health/ping');
  console.log(`1. Health: ${h.s} → ${h.d?.status}`);

  // 2. Login
  const l = await req('POST', '/auth/login', { email:'admin@gym.com', password:'admin' });
  console.log(`2. Login: ${l.s}`);
  if (l.d?.accessToken) {
    TOKEN = l.d.accessToken;
    SUCURSAL_ID = l.d.user?.sucursales?.[0]?.id;
    console.log(`   ✅ Token OK | Sucursal: ${SUCURSAL_ID}`);
  } else {
    console.log(`   ❌ ${JSON.stringify(l.d)}`);
    return;
  }

  // 3. Clientes
  const c = await req('GET', '/clientes');
  console.log(`3. Clientes: ${c.s} | Total: ${Array.isArray(c.d)?c.d.length:'ERR'}`);

  // 4. Crear cliente
  const nc = await req('POST', '/clientes', { nombre:'María López', telefono:'55501234' });
  console.log(`4. Crear Cliente: ${nc.s} → ${nc.d?.nombre || JSON.stringify(nc.d)}`);

  // 5. Planes
  const p = await req('GET', '/planes');
  console.log(`5. Planes: ${p.s} | Total: ${Array.isArray(p.d)?p.d.length:'ERR'}`);
  if (Array.isArray(p.d)) p.d.forEach(x => console.log(`   - ${x.nombre} (${x.dias}d) Q${(x.precio_centavos/100)}`));

  // 6. Sucursales
  const s = await req('GET', '/sucursales');
  console.log(`6. Sucursales: ${s.s} | Total: ${Array.isArray(s.d)?s.d.length:'ERR'}`);

  // 7. Productos
  const pr = await req('GET', '/inventario/productos');
  console.log(`7. Productos: ${pr.s} | Total: ${Array.isArray(pr.d)?pr.d.length:'ERR'}`);

  // 8. Caja
  const ca = await req('GET', '/caja/abierta');
  console.log(`8. Caja: ${ca.s} → ${JSON.stringify(ca.d)?.substring(0,100)}`);

  // 9. Reportes
  const rp = await req('GET', '/reportes/resumen-dia');
  console.log(`9. Reportes: ${rp.s} → ${JSON.stringify(rp.d)?.substring(0,150)}`);

  // 10. Clientes final
  const cf = await req('GET', '/clientes');
  console.log(`\n10. Clientes finales: ${cf.s}`);
  if (Array.isArray(cf.d)) cf.d.forEach(x => console.log(`   → ${x.nombre} | ${x.telefono||'-'} | ${x.estado}`));

  console.log('\n═══ RESUMEN ═══');
  console.log(`Health:      ${h.s===200?'✅':'❌'} (${h.s})`);
  console.log(`Login:       ${l.s===201||l.s===200?'✅':'❌'} (${l.s})`);
  console.log(`Clientes:    ${c.s===200?'✅':'❌'} (${c.s})`);
  console.log(`Crear Cli:   ${nc.s===201?'✅':'❌'} (${nc.s})`);
  console.log(`Planes:      ${p.s===200?'✅':'❌'} (${p.s})`);
  console.log(`Sucursales:  ${s.s===200?'✅':'❌'} (${s.s})`);
  console.log(`Productos:   ${pr.s===200?'✅':'❌'} (${pr.s})`);
  console.log(`Caja:        ${ca.s===200||ca.s===404?'✅':'❌'} (${ca.s})`);
  console.log(`Reportes:    ${rp.s===200?'✅':'❌'} (${rp.s})`);
}

main();
