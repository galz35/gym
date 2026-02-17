const https = require('https');

const BASE_URL = 'https://gym-fxzy.onrender.com';
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
    return new Promise((resolve, reject) => {
        const url = new URL(BASE_URL + path);
        const options = {
            method: method,
            headers: {
                'Content-Type': 'application/json',
            },
            timeout: 15000
        };

        if (token) {
            options.headers['Authorization'] = `Bearer ${token}`;
        }

        if (sucursalId) {
            options.headers['X-Sucursal-Id'] = sucursalId;
        }

        console.log(`\n[${method}] ${path}...`);

        const req = https.request(url, options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                console.log(`Status: ${res.statusCode}`);

                try {
                    const parsed = data ? JSON.parse(data) : null;
                    if (res.statusCode >= 200 && res.statusCode < 300) {
                        resolve(parsed);
                    } else {
                        console.error('Error Response:', JSON.stringify(parsed, null, 2));
                        resolve(null);
                    }
                } catch (e) {
                    console.error('Raw (Non-JSON) Response:', data);
                    resolve(null);
                }
            });
        });

        req.on('error', (e) => {
            console.error(`Request Error: ${e.message}`);
            resolve(null);
        });

        if (body) {
            req.write(JSON.stringify(body));
        }
        req.end();
    });
}

async function runTests() {
    console.log('--- STARTING API TESTS (v3) ---');

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
    console.log('Login successful.');

    // 2. GET PROFILE & SUCURSAL
    const profile = await request('GET', '/auth/profile');
    if (profile && profile.sucursales && profile.sucursales.length > 0) {
        sucursalId = profile.sucursales[0].id;
        console.log(`Using Sucursal ID: ${sucursalId}`);
    } else {
        console.warn('No sucursales in profile. Fetching manually...');
        const sucursales = await request('GET', '/sucursales');
        if (sucursales && sucursales.length > 0) {
            sucursalId = sucursales[0].id;
            console.log(`Fallback Sucursal ID: ${sucursalId}`);
        }
    }

    if (!sucursalId) {
        console.error('CRITICAL: No Sucursal ID available.');
        // Try creating one if completely failing? 
        // For now, continue but expect failures.
    }

    // 3. CLIENTES: LIST
    const clientes = await request('GET', '/clientes');
    console.log(`Clients found: ${clientes ? clientes.length : 0}`);

    // 4. CLIENTES: CREATE
    const newClient = await request('POST', '/clientes', {
        nombre: `Test Client ${Date.now()}`,
        email: `test${Date.now()}@example.com`,
        telefono: '5550000',
        documento: `DOC-${Date.now()}`
    });

    if (newClient) {
        clienteId = newClient.id;
        console.log(`Created Client ID: ${clienteId}`);
    }

    // 6. INVENTARIO: CREATE PRODUCT
    const newProduct = await request('POST', '/inventario/productos', {
        nombre: `Protein Shake ${Date.now()}`,
        categoria: 'Suplementos',
        precio: 50.00, // DTO uses 'precio' (number) NOT precioCentavos
        costo: 30.00
    });

    if (newProduct) {
        productoId = newProduct.id;
        console.log(`Created Product ID: ${productoId}`);
    }

    // 8. INVENTARIO: STOCK
    if (sucursalId) {
        await request('GET', `/inventario/stock/${sucursalId}`);
    }

    // 10. PLANES: CREATE
    const newPlan = await request('POST', '/planes', {
        nombre: `Gold Plan ${Date.now()}`,
        precio: 450.00,  // DTO uses 'precio' (number)
        tipo: 'MENSUAL', // Now supported
        visitas: 0,
        multisede: false,
        estado: 'ACTIVO' // Not in CreateDTO but maybe ignored
    });

    if (newPlan) {
        planId = newPlan.id;
        console.log(`Created Plan ID: ${planId}`);
    }

    // 11. MEMBRESIAS: CREATE
    if (clienteId && planId && sucursalId) {
        const membership = await request('POST', '/membresias', {
            cliente_id: clienteId, // Service uses snake_case in DTO check? Controler uses "any" DTO.
            // Service: "dto.plan_id", "dto.sucursal_id".
            // Let's check MembresiasService.create: 
            // "where: { id: dto.plan_id }"
            // So we MUST send snake_case to this endpoint based on current service implementation exposed as "any"
            plan_id: planId,
            sucursal_id: sucursalId,
            inicio: new Date().toISOString()
        });
        if (membership) {
            console.log(`Created Membership ID: ${membership.id}`);
        }
    }

    // 12. CAJA: OPEN
    if (sucursalId) {
        // Check my open box
        const caja = await request('GET', '/caja/abierta');
        if (caja) {
            cajaId = caja.id;
            console.log(`Caja already open. ID: ${cajaId}`);
        } else {
            console.log('No open box found. Attempting to open...');
            const openCaja = await request('POST', '/caja/abrir', {
                sucursalId: sucursalId,
                montoApertura: 10000 // 100.00 centavos? Or DTO says number?
                // DTO: @IsNumber() montoApertura. Service: BigInt(dto.montoApertura)
                // So pass integer centavos.
            });
            if (openCaja) {
                cajaId = openCaja.id;
                console.log(`Opened Caja ID: ${cajaId}`);
            }
        }

        // Test new endpoint
        await request('GET', `/caja/estado/${sucursalId}`);
    }

    console.log('--- TESTS COMPLETED ---');
}

runTests();
