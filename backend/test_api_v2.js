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
let cajaId = ''; // Global variable for cajaId, initialized empty

// Helper function to make requests
async function request(method, path, body = null) {
    return new Promise((resolve, reject) => {
        const url = new URL(BASE_URL + path);
        const options = {
            method: method,
            headers: {
                'Content-Type': 'application/json',
            },
            timeout: 15000 // 15s timeout
        };

        if (token) {
            options.headers['Authorization'] = `Bearer ${token}`;
        }

        if (sucursalId) {
            options.headers['X-Sucursal-Id'] = sucursalId;
        }

        console.log(`\n[${method}] ${path}...`);
        const start = Date.now();

        const req = https.request(url, options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                const duration = Date.now() - start;
                console.log(`Status: ${res.statusCode} (${duration}ms)`);

                try {
                    const parsed = data ? JSON.parse(data) : null;
                    if (res.statusCode >= 200 && res.statusCode < 300) {
                        resolve(parsed);
                    } else {
                        console.error('Error Body:', JSON.stringify(parsed, null, 2));
                        resolve(null); // Resolve null to continue testing other endpoints
                    }
                } catch (e) {
                    console.error('Raw Response:', data);
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
    console.log('--- STARTING API TESTS (v2) ---');

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
        console.log(`Using Sucursal ID (from profile): ${sucursalId}`);
    } else {
        console.warn('No sucursales in profile. Fetching manually...');
        const sucursales = await request('GET', '/sucursales');
        if (sucursales && sucursales.length > 0) {
            sucursalId = sucursales[0].id;
            console.log(`Fallback Sucursal ID: ${sucursalId}`);
        } else {
            console.error('NO SUCURSALES FOUND. Creating one...');
            const newSucursal = await request('POST', '/sucursales', {
                nombre: 'Sucursal Test Script',
                direccion: 'Calle Falsa 123',
                telefono: '555-1234'
            });
            if (newSucursal) {
                sucursalId = newSucursal.id;
                console.log(`Created new Sucursal ID: ${sucursalId}`);
            }
        }
    }

    if (!sucursalId) {
        console.error('CRITICAL: No Sucursal ID available. Many tests will fail.');
    }

    // 3. CLIENTES: LIST
    const clientes = await request('GET', '/clientes');
    console.log(`Clients found: ${clientes ? clientes.length : 0}`);

    // 4. CLIENTES: CREATE (Check if DTO requires empresaId or not. Assuming NOT based on typical NestJS+Passport)
    const newClient = await request('POST', '/clientes', {
        nombre: `Test Client ${Date.now()}`,
        email: `test${Date.now()}@example.com`,
        telefono: '555-0000',
        documento: `DOC-${Date.now()}`
        // Removed empresaId
    });

    if (newClient) {
        clienteId = newClient.id;
        console.log(`Created Client ID: ${clienteId}`);
    } else {
        console.error('Failed to create client.');
    }

    // 5. CLIENTES: UPDATE
    if (clienteId) {
        await request('PUT', `/clientes/${clienteId}`, {
            nombre: `Test Client Updated ${Date.now()}`
        });
    }

    // 6. INVENTARIO: LIST PRODUCTS
    const productos = await request('GET', '/inventario/productos');
    console.log(`Products found: ${productos ? productos.length : 0}`);

    // 7. INVENTARIO: CREATE PRODUCT
    const newProduct = await request('POST', '/inventario/productos', {
        nombre: `Protein Shake ${Date.now()}`,
        categoria: 'Suplementos',
        precioCentavos: 5000,
        costoCentavos: 3000,
        estado: 'ACTIVO'
        // Removed empresaId
    });

    if (newProduct) {
        productoId = newProduct.id;
        console.log(`Created Product ID: ${productoId}`);
    } else {
        console.error('Failed to create product.');
    }

    // 8. INVENTARIO: STOCK
    if (sucursalId) {
        await request('GET', `/inventario/stock/${sucursalId}`);
    }

    // 9. PLANES: LIST
    const planes = await request('GET', '/planes');
    console.log(`Plans found: ${planes ? planes.length : 0}`);

    // 10. PLANES: CREATE
    const newPlan = await request('POST', '/planes', {
        nombre: `Gold Plan ${Date.now()}`,
        precioCentavos: 45000,
        dias: 30,
        tipo: 'MENSUAL', // Add typical fields
        visitas: 0,
        multisede: false,
        estado: 'ACTIVO'
        // Removed empresaId
    });

    if (newPlan) {
        planId = newPlan.id;
        console.log(`Created Plan ID: ${planId}`);
    } else {
        console.error('Failed to create plan.');
    }

    // 11. MEMBRESIAS: CREATE (Assign to client)
    if (clienteId && planId && sucursalId) {
        const membership = await request('POST', '/membresias', {
            clienteId: clienteId,
            planId: planId,
            sucursalId: sucursalId,
            inicio: new Date().toISOString()
        });
        if (membership) {
            console.log(`Created Membership ID: ${membership.id}`);
        } else {
            console.error('Failed to create membership.');
        }
    }

    // 12. CAJA: OPEN (If not open)
    if (sucursalId) {
        // Check active session first? Or just try to open
        const caja = await request('GET', `/caja/estado/${sucursalId}`);
        if (caja && caja.estado === 'CERRADA') {
            const openCaja = await request('POST', '/caja/abrir', {
                sucursalId: sucursalId,
                montoInicial: 10000 // 100.00
            });
            if (openCaja) {
                cajaId = openCaja.id;
                console.log(`Opened Caja ID: ${cajaId}`);
            }
        } else if (caja && caja.estado === 'ABIERTA') {
            cajaId = caja.id;
            console.log(`Caja already open. ID: ${cajaId}`);
        } else {
            // Maybe no caja at all? Create one?
            // Assuming endpoint handles it.
            // If 404, maybe NO caja created for sucursal yet?
            // Try fetching /caja/sucursal/:id list
        }
    }

    console.log('--- TESTS COMPLETED ---');
}

runTests();
