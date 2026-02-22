// test using native fetch

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

    console.log('--- EMPEZANDO TESTS E2E PROFUNDOS ---');

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

    // 2. CREACIÓN DE CLIENTE (POST)
    try {
        console.log('>> Probando 2: Crear Cliente (POST)...');
        const clienteRes = await fetch(`${BASE_URL}/clientes`, {
            method: 'POST',
            headers: headers(),
            body: JSON.stringify({
                nombre: 'Cliente Test E2E',
                telefono: '555-1234',
                email: 'test@gym.com',
                empresaId: EMPRESA_ID // Inyectado por flutter
            })
        });
        const cliente = await clienteRes.json();
        if (!cliente.id) throw Error('No ID retornado. Falló escritura. ' + JSON.stringify(cliente));
        clienteId = cliente.id;
        console.log(`✅ Cliente creado. ID: ${clienteId}`);
    } catch (e) {
        console.error('❌ Falla en Creación Cliente:', e.message);
    }

    // 3. ACTUALIZACIÓN DE CLIENTE (PUT)
    try {
        console.log('>> Probando 3: Actualizar Cliente (PATCH/PUT)...');
        const upRes = await fetch(`${BASE_URL}/clientes/${clienteId}`, {
            method: 'PATCH',
            headers: headers(),
            body: JSON.stringify({
                nombre: 'Cliente Modificado E2E',
                telefono: '555-9999'
            })
        });
        const upClient = await upRes.json();
        if (upClient.telefono !== '555-9999') throw Error('Actualización no reflejada');
        console.log('✅ Cliente modificado con éxito.');
    } catch (e) {
        console.error('❌ Falla en Actualización Cliente:', e.message);
    }

    // 4. CREAR PLAN
    try {
        console.log('>> Probando 4: Crear Plan Membresía...');
        const planRes = await fetch(`${BASE_URL}/planes`, {
            method: 'POST',
            headers: headers(),
            body: JSON.stringify({
                nombre: 'Plan Test E2E',
                tipo: 'SEMANAL',
                precio: 100,
                dias: 7,
                sucursalId: sucursalId
            })
        });
        const plan = await planRes.json();
        if (!plan.id) throw Error('No se creó el plan: ' + JSON.stringify(plan));
        planId = plan.id;
        console.log(`✅ Plan creado. ID: ${planId}`);
    } catch (e) {
        console.error('❌ Falla en Creación Plan:', e.message);
    }

    // 5. ASIGNAR MEMBRESIA 
    try {
        console.log('>> Probando 5: Asignar Membresía a Cliente...');
        const dateInicio = new Date().toISOString();
        const memRes = await fetch(`${BASE_URL}/membresias`, {
            method: 'POST',
            headers: headers(),
            body: JSON.stringify({
                cliente_id: clienteId,
                plan_id: planId,
                sucursal_id: sucursalId,
                inicio: dateInicio,
                estado: 'ACTIVA'
            })
        });
        const mem = await memRes.json();
        if (!mem.id) throw Error('No se asignó membresía: ' + JSON.stringify(mem));
        membresiaId = mem.id;
        console.log(`✅ Membresía asignada. ID: ${membresiaId}`);
    } catch (e) {
        console.error('❌ Falla en Asignación Membresía:', e.message);
    }

    // 6. VALIDAR ASISTENCIA (CheckIn)
    try {
        console.log('>> Probando 6: Check-in del Cliente...');
        const ckRes = await fetch(`${BASE_URL}/asistencia/validar`, {
            method: 'POST',
            headers: headers(),
            body: JSON.stringify({
                clienteId: clienteId,
                sucursalId: sucursalId
            })
        });
        const ck = await ckRes.json();
        if (!ck.resultado) throw Error('Asistencia no validada: ' + JSON.stringify(ck));
        console.log(`✅ Check-in Exitoso. Resultado: ${ck.resultado}, Nota: ${ck.nota}`);
    } catch (e) {
        console.error('❌ Falla en Check-in:', e.message);
    }

    // 7. FLUJO DE CAJA (Cerrar caja anterior, abrir nueva, vender)
    try {
        console.log('>> Probando 7: Configuración de Caja y Ventas (POS)...');

        // Check si hay caja abierta, si hay, la cerramos
        let cajRes = await fetch(`${BASE_URL}/caja/abierta`, { headers: headers() });
        let cajJson = await cajRes.json();

        if (cajJson && cajJson.id) {
            console.log('   - Caja previa detectada. Cerrando caja vieja para la prueba...');
            await fetch(`${BASE_URL}/caja/${cajJson.id}/cerrar`, {
                method: 'POST',
                headers: headers(),
                body: JSON.stringify({ montoCierre: 1000 })
            });
        }

        console.log('   - Abriendo nueva caja...');
        let opCaj = await fetch(`${BASE_URL}/caja/abrir`, {
            method: 'POST',
            headers: headers(),
            body: JSON.stringify({ sucursalId, montoApertura: 50.0 })
        });
        let c = await opCaj.json();
        cajaId = c.id;
        if (!cajaId) throw Error('Error abriendo caja: ' + JSON.stringify(c));
        console.log('✅ Caja Abierta.');

        console.log('   - Registrando Venta de Prueba...');
        let saleRes = await fetch(`${BASE_URL}/ventas`, {
            method: 'POST',
            headers: headers(),
            body: JSON.stringify({
                sucursalId,
                cajaId,
                clienteId: null,
                totalCentavos: 500,
                detalles: [],
                pagos: [{ monto: 500, metodo: 'EFECTIVO' }],
                empresaId: EMPRESA_ID
            })
        });
        let sale = await saleRes.json();
        if (!sale.id) throw Error('No se registró la venta: ' + JSON.stringify(sale));
        console.log(`✅ Venta Exitosa. Venta ID: ${sale.id}. POS Operativo al 100%.`);

    } catch (e) {
        console.error('❌ Falla en Flujo Caja/Ventas:', e.message);
    }

    console.log('--- TESTS E2E FINALIZADOS COMPLETAMENTE ---');
}

runTests();
