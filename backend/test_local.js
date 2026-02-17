const http = require('http'); // Changed to http for local

const BASE_URL = 'http://127.0.0.1:3000';
const EMPRESA_ID = 'b741a91f-47b0-4963-a65a-94b77cbc9b94';
const USER_EMAIL = 'admin@gympro.com';
const USER_PASS = 'admin123';

let token = '';
let sucursalId = '';
let clienteId = '';
let productoId = '';
let planId = '';
let cajaId = '';

async function request(method, path, body = null) {
    const start = Date.now();
    return new Promise((resolve, reject) => {
        const url = new URL(BASE_URL + path);
        const options = {
            method: method,
            headers: {
                'Content-Type': 'application/json',
            },
            timeout: 5000
        };

        if (token) {
            options.headers['Authorization'] = `Bearer ${token}`;
        }

        if (sucursalId) {
            options.headers['X-Sucursal-Id'] = sucursalId;
        }

        console.log(`[${method}] ${path}...`);

        const req = http.request(url, options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                const duration = Date.now() - start;
                console.log(`  - Status: ${res.statusCode} | Time: ${duration}ms`);

                try {
                    const parsed = data ? JSON.parse(data) : null;
                    if (res.statusCode >= 200 && res.statusCode < 300) {
                        resolve(parsed);
                    } else {
                        console.error('  - Error Response:', JSON.stringify(parsed, null, 2));
                        resolve(null);
                    }
                } catch (e) {
                    console.error('  - Raw (Non-JSON) Response:', data);
                    resolve(null);
                }
            });
        });

        req.on('error', (e) => {
            console.error(`  - Request Error: ${e.message}`);
            resolve(null);
        });

        if (body) {
            req.write(JSON.stringify(body));
        }
        req.end();
    });
}

async function runTests() {
    console.log('=== STARTING LOCAL API TESTS ===');

    // 1. LOGIN
    const auth = await request('POST', '/auth/login', {
        email: USER_EMAIL,
        password: USER_PASS,
        empresaId: EMPRESA_ID
    });

    if (!auth || !auth.accessToken) {
        console.error('LOGIN FAILED. ABORTING.');
        return;
    }
    token = auth.accessToken;
    console.log('  - Login successful.');

    // 2. GET PROFILE
    const profile = await request('GET', '/auth/profile');
    if (profile && profile.sucursales && profile.sucursales.length > 0) {
        sucursalId = profile.sucursales[0].id;
        console.log(`  - Using Sucursal ID: ${sucursalId}`);
    } else {
        console.warn('  - No sucursales in profile. Fetching manually...');
        const sucursales = await request('GET', '/sucursales');
        if (sucursales && sucursales.length > 0) {
            sucursalId = sucursales[0].id;
            console.log(`  - Fallback Sucursal ID: ${sucursalId}`);
        }
    }

    // 3. CLIENTES: LIST
    const clientes = await request('GET', '/clientes');
    console.log(`  - Clients count: ${clientes ? clientes.length : 0}`);

    // 4. CLIENTES: CREATE
    const newClient = await request('POST', '/clientes', {
        nombre: 'Teo Test Local',
        email: 'teo@local.com',
        telefono: '123456',
        documento: 'LOCAL-1'
    });
    if (newClient) {
        clienteId = newClient.id;
        console.log(`  - Created Client ID: ${clienteId}`);
    }

    // 5. PLANES: CREATE
    const newPlan = await request('POST', '/planes', {
        nombre: 'Plan Local Mensual',
        precio: 50.00,
        tipo: 'MENSUAL',
        visitas: 0
    });
    if (newPlan) {
        planId = newPlan.id;
        console.log(`  - Created Plan ID: ${planId}`);
        console.log(`  - Plan Days (auto-filled?): ${newPlan.dias}`);
    }

    // 6. MEMBRESIAS: CREATE
    if (clienteId && planId && sucursalId) {
        const membership = await request('POST', '/membresias', {
            cliente_id: clienteId,
            plan_id: planId,
            sucursal_id: sucursalId,
            inicio: new Date().toISOString()
        });
        if (membership) {
            console.log(`  - Created Membership ID: ${membership.id}`);
            console.log(`  - End Date: ${membership.fin}`);
        }
    }

    // 7. INVENTARIO: GET PRODUCT
    const products = await request('GET', '/inventario/productos');
    const prodId = products && products.length > 0 ? products[0].id : null;

    // 8. VENTAS: SIMULATE SALE
    if (prodId && sucursalId && clienteId) {
        const openedCaja = await request('GET', '/caja/abierta');
        if (openedCaja) {
            const newSale = await request('POST', '/ventas', {
                sucursalId: sucursalId,
                cajaId: openedCaja.id,
                clienteId: clienteId,
                totalCentavos: 15000,
                detalles: [
                    { productoId: prodId, cantidad: 1, precioUnit: 15000, subtotal: 15000 }
                ],
                pagos: [
                    { monto: 15000, metodo: 'EFECTIVO' }
                ]
            });
            if (newSale) console.log(`  - Created Sale ID: ${newSale.id}`);
        }
    }

    // 9. REPORTES: CHECK DASHBOARD
    if (sucursalId) {
        const report = await request('GET', `/reportes/resumen-dia?sucursalId=${sucursalId}`);
        if (report) console.log('  - Dashboard stats received successfully');
    }

    console.log('=== LOCAL TESTS COMPLETED ===');
}

runTests();
