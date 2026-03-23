const http = require('https');

const BASE = 'https://rhclaroni.com/apig';
let TOKEN = null;
let EMPRESA_ID = null;
let SUCURSAL_ID = null;

async function req(method, path, body = null) {
  const url = new URL(BASE + path);
  const options = {
    hostname: url.hostname,
    path: url.pathname,
    method,
    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
    rejectUnauthorized: false,
  };
  if (TOKEN) options.headers['Authorization'] = `Bearer ${TOKEN}`;
  if (SUCURSAL_ID) options.headers['X-Sucursal-Id'] = SUCURSAL_ID;

  return new Promise((resolve) => {
    const r = http.request(options, (res) => {
      let data = '';
      res.on('data', (d) => data += d);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, data: JSON.parse(data) }); }
        catch { resolve({ status: res.statusCode, data }); }
      });
    });
    r.on('error', (e) => resolve({ status: 0, data: e.message }));
    if (body) r.write(JSON.stringify(body));
    r.end();
  });
}

async function main() {
  console.log('═══════════════════════════════════════════');
  console.log('    TEST COMPLETO DEL BACKEND GYM');
  console.log('═══════════════════════════════════════════\n');

  // 1. Health
  console.log('── 1. Health Ping ──');
  const health = await req('GET', '/health/ping');
  console.log(`   Status: ${health.status} | DB: ${health.data?.status}`);
  
  // 2. Login
  console.log('\n── 2. Login ──');
  const login = await req('POST', '/auth/login', {
    email: 'admin@gym.com',
    password: 'admin',
    empresaId: 'b741a91f-47b0-4963-a65a-94b77cbc9b94',
  });
  console.log(`   Status: ${login.status}`);
  if (login.data?.accessToken) {
    TOKEN = login.data.accessToken;
    EMPRESA_ID = login.data.user?.empresaId;
    console.log(`   ✅ Token obtenido`);
    console.log(`   Empresa: ${EMPRESA_ID}`);
    console.log(`   Usuario: ${login.data.user?.nombre}`);
    console.log(`   Sucursales: ${JSON.stringify(login.data.user?.sucursales?.map(s => ({id: s.id, nombre: s.nombre})))}`);
    if (login.data.user?.sucursales?.length > 0) {
      SUCURSAL_ID = login.data.user.sucursales[0].id;
      console.log(`   Sucursal activa: ${SUCURSAL_ID}`);
    }
  } else {
    console.log(`   ❌ Login falló: ${JSON.stringify(login.data)}`);
    // Try to seed first
    console.log('\n── 2b. No hay usuario, intentando seed ──');
    return;
  }

  // 3. Listar clientes
  console.log('\n── 3. GET /clientes ──');
  const clientes = await req('GET', '/clientes');
  console.log(`   Status: ${clientes.status} | Count: ${Array.isArray(clientes.data) ? clientes.data.length : 'N/A'}`);

  // 4. Crear un cliente de prueba
  console.log('\n── 4. POST /clientes (Crear) ──');
  const nuevoCliente = await req('POST', '/clientes', {
    nombre: 'Juan Pérez Test',
    telefono: '55512345',
    email: 'juan@test.com',
  });
  console.log(`   Status: ${nuevoCliente.status}`);
  if (nuevoCliente.data?.id) {
    console.log(`   ✅ Cliente creado: ${nuevoCliente.data.id} - ${nuevoCliente.data.nombre}`);
  } else {
    console.log(`   ❌ Error: ${JSON.stringify(nuevoCliente.data)}`);
  }

  // 5. Listar planes
  console.log('\n── 5. GET /planes ──');
  const planes = await req('GET', '/planes');
  console.log(`   Status: ${planes.status} | Count: ${Array.isArray(planes.data) ? planes.data.length : 'N/A'}`);
  if (planes.status !== 200 || (Array.isArray(planes.data) && planes.data.length === 0)) {
    console.log(`   ⚠️  No hay planes. Intentando crear uno...`);
    const plan = await req('POST', '/planes', {
      nombre: 'Día',
      tipo: 'DIAS',
      dias: 1,
      precio_centavos: 5000,
    });
    console.log(`   Plan día: ${plan.status} - ${JSON.stringify(plan.data?.id || plan.data)}`);
    
    const planSem = await req('POST', '/planes', {
      nombre: 'Semana',
      tipo: 'DIAS',
      dias: 7,
      precio_centavos: 25000,
    });
    console.log(`   Plan semana: ${planSem.status} - ${JSON.stringify(planSem.data?.id || planSem.data)}`);
    
    const planMes = await req('POST', '/planes', {
      nombre: 'Mes',
      tipo: 'DIAS',
      dias: 30,
      precio_centavos: 80000,
    });
    console.log(`   Plan mes: ${planMes.status} - ${JSON.stringify(planMes.data?.id || planMes.data)}`);
  }

  // 6. Listar sucursales
  console.log('\n── 6. GET /sucursales ──');
  const sucursales = await req('GET', '/sucursales');
  console.log(`   Status: ${sucursales.status} | Data: ${JSON.stringify(sucursales.data)}`);

  // 7. Inventario / Productos
  console.log('\n── 7. GET /inventario/productos ──');
  const productos = await req('GET', '/inventario/productos');
  console.log(`   Status: ${productos.status} | Count: ${Array.isArray(productos.data) ? productos.data.length : 'N/A'}`);

  // 8. Caja
  console.log('\n── 8. GET /caja/abierta (verificar caja) ──');
  const cajaAbierta = await req('GET', '/caja/abierta');
  console.log(`   Status: ${cajaAbierta.status} | Data: ${JSON.stringify(cajaAbierta.data)?.substring(0, 200)}`);

  // 9. Reportes
  console.log('\n── 9. GET /reportes/resumen-dia ──');
  const resumen = await req('GET', '/reportes/resumen-dia');
  console.log(`   Status: ${resumen.status} | Data: ${JSON.stringify(resumen.data)?.substring(0, 200)}`);

  // 10. Verificar clientes finales
  console.log('\n── 10. GET /clientes (final) ──');
  const clientesFinal = await req('GET', '/clientes');
  console.log(`   Status: ${clientesFinal.status} | Total: ${Array.isArray(clientesFinal.data) ? clientesFinal.data.length : 'N/A'}`);
  if (Array.isArray(clientesFinal.data)) {
    clientesFinal.data.forEach(c => console.log(`      - ${c.nombre} | ${c.telefono || '-'} | ${c.estado}`));
  }

  console.log('\n═══════════════════════════════════════════');
  console.log('    RESUMEN');
  console.log('═══════════════════════════════════════════');
  console.log(`   Health:    ${health.status === 200 ? '✅' : '❌'}`);
  console.log(`   Login:     ${login.status === 200 || login.status === 201 ? '✅' : '❌'}`);
  console.log(`   Clientes:  ${clientes.status === 200 ? '✅' : '❌'}`);
  console.log(`   Crear Cli: ${nuevoCliente.status === 201 ? '✅' : '❌'}`);
  console.log(`   Planes:    ${planes.status === 200 ? '✅' : '❌'}`);
  console.log(`   Sucursal:  ${sucursales.status === 200 ? '✅' : '❌'}`);
  console.log(`   Productos: ${productos.status === 200 ? '✅' : '❌'}`);
  console.log(`   Caja:      ${cajaAbierta.status === 200 ? '✅' : '❌'}`);
  console.log(`   Reportes:  ${resumen.status === 200 ? '✅' : '❌'}`);
}

main().catch(console.error);
