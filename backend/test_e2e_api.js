// test using native fetch
// Corrected to match real NestJS Endpoints

const BASE_URL = 'https://gym-fxzy.onrender.com';
const ADMIN_EMAIL = 'admin@gympro.com';
const ADMIN_PASS = '123456';
const EMPRESA_ID = 'b741a91f-47b0-4963-a65a-94b77cbc9b94';

async function runTests() {
    let token = '';
    let sucursalId = '';
    let clienteId = '';
    let cajaId = '';
    let planId = '';
    let membresiaId = '';

    const headers = () => ({
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
        'X-Sucursal-Id': sucursalId
    });

    console.log('--- EMPEZANDO TESTS E2E CORRECTOS PARA RENDER ---');

    // 1. LOGIN
    try {
        console.log('>> Probando 1: Autenticación / Login...');
        const loginRes = await fetch(`${BASE_URL}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email: ADMIN_EMAIL, password: ADMIN_PASS, empresaId: EMPRESA_ID })
        });
        const auth = await loginRes.json();
        if (!auth.accessToken) throw Error('No access token:' + JSON.stringify(auth));
        token = auth.accessToken;
        sucursalId = auth.user.sucursales[0].id;
        console.log('✅ Login exitoso. Token obtenido.');
    } catch (e) {
        console.error('❌ Falta Crítica en Login:', e.message);
        return;
    }

    // 2. CREACIÓN DE CLIENTE
    try {
        console.log('>> Probando 2: Crear Cliente (POST)...');
        const clienteRes = await fetch(`${BASE_URL}/clientes`, {
            method: 'POST',
            headers: headers(),
            body: JSON.stringify({
                nombre: 'Cliente Test E2E Render',
                telefono: '555-0000',
                email: 'render@gym.com',
                empresaId: EMPRESA_ID
            })
        });
        const cliente = await clienteRes.json();
        if (!cliente.id) throw Error('No ID retornado: ' + JSON.stringify(cliente));
        clienteId = cliente.id;
        console.log(`✅ Cliente creado. ID: ${clienteId}`);
    } catch (e) {
        console.error('❌ Falla en Creación Cliente:', e.message);
    }

    // 3. CREAR PLAN
    try {
        console.log('>> Probando 3: Crear Plan Membresía...');
        const planRes = await fetch(`${BASE_URL}/planes`, {
            method: 'POST',
            headers: headers(),
            body: JSON.stringify({
                nombre: 'Plan E2E 30 Dias',
                tipo: 'MENSUAL',
                precio: 500,
                dias: 30,
                sucursalId: sucursalId // Algunos en el DTO lo piden o lo ignoran y usan empresaId
            })
        });
        const plan = await planRes.json();
        if (!plan.id) throw Error('No se creó el plan: ' + JSON.stringify(plan));
        planId = plan.id;
        console.log(`✅ Plan creado. ID: ${planId}`);
    } catch (e) {
        console.error('❌ Falla en Creación Plan:', e.message);
    }

    // 4. ASIGNAR MEMBRESIA 
    try {
        console.log('>> Probando 4: Asignar Membresía...');
        const memRes = await fetch(`${BASE_URL}/membresias`, {
            method: 'POST',
            headers: headers(),
            body: JSON.stringify({
                cliente_id: clienteId,
                plan_id: planId,
                sucursal_id: sucursalId,
                inicio: new Date().toISOString(),
                estado: 'ACTIVA'
            })
        });
        const mem = await memRes.json();
        if (!mem.id) throw Error('Error al asignar: ' + JSON.stringify(mem));
        membresiaId = mem.id;
        console.log(`✅ Membresía asignada. ID: ${membresiaId}`);
    } catch (e) {
        console.error('❌ Falla en Membresía:', e.message);
    }

    // 5. CAJA: ABRIR
    try {
        console.log('>> Probando 5: Gestión de Caja...');
        const opCaj = await fetch(`${BASE_URL}/caja/abrir`, {
            method: 'POST',
            headers: headers(),
            body: JSON.stringify({ sucursalId, montoApertura: 100 })
        });
        const c = await opCaj.json();
        if (!c.id) {
            console.log('   - (Caja ya abierta o error, continuando con ID si existe)');
            const status = await fetch(`${BASE_URL}/caja/abierta`, { headers: headers() });
            const sJson = await status.json();
            cajaId = sJson.id;
        } else {
            cajaId = c.id;
        }
        if (!cajaId) throw Error('No se pudo obtener una caja abierta.');
        console.log(`✅ Caja Operativa. ID: ${cajaId}`);
    } catch (e) {
        console.error('❌ Falla en Caja:', e.message);
    }

    // 6. VENTAS (POS)
    try {
        console.log('>> Probando 6: Venta POS...');
        const saleRes = await fetch(`${BASE_URL}/ventas`, {
            method: 'POST',
            headers: headers(),
            body: JSON.stringify({
                sucursalId,
                cajaId,
                totalCentavos: 1500,
                detalles: [],
                pagos: [{ monto: 1500, metodo: 'EFECTIVO' }]
            })
        });
        const sale = await saleRes.json();
        if (!sale.id) throw Error('Error en venta: ' + JSON.stringify(sale));
        console.log(`✅ Venta Exitosa. ID: ${sale.id}`);
    } catch (e) {
        console.error('❌ Falla en Venta:', e.message);
    }

    // 7. ASISTENCIA (Checkin) -> /asistencia/checkin
    try {
        console.log('>> Probando 7: Check-in...');
        const ckRes = await fetch(`${BASE_URL}/asistencia/checkin`, {
            method: 'POST',
            headers: headers(),
            body: JSON.stringify({
                clienteId: clienteId,
                sucursalId: sucursalId
            })
        });
        const ck = await ckRes.json();
        if (!ck.resultado) throw Error('Error en checkin: ' + JSON.stringify(ck));
        console.log(`✅ Check-in OK. (${ck.resultado})`);
    } catch (e) {
        console.error('❌ Falla en Check-in:', e.message);
    }

    console.log('--- TESTS FINALIZADOS PARA RENDER ---');
}

runTests();
