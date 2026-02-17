const https = require('https');

const BASE_URL = 'https://gym-fxzy.onrender.com';
const EMPRESA_ID = 'b741a91f-47b0-4963-a65a-94b77cbc9b94';
const USER_EMAIL = 'admin@gympro.com';
const USER_PASS = 'admin123';

let token = '';
let sucursalId = '';

async function request(method, path, body = null) {
    return new Promise((resolve) => {
        const url = new URL(BASE_URL + path);
        const options = {
            method: method,
            headers: { 'Content-Type': 'application/json' }
        };
        if (token) options.headers['Authorization'] = `Bearer ${token}`;
        if (sucursalId) options.headers['X-Sucursal-Id'] = sucursalId;

        const req = https.request(url, options, (res) => {
            let data = '';
            res.on('data', (c) => data += c);
            res.on('end', () => {
                console.log(`[${method}] ${path} - Status: ${res.statusCode}`);
                try {
                    const parsed = data ? JSON.parse(data) : null;
                    if (res.statusCode >= 400) console.log('Error Body:', JSON.stringify(parsed, null, 2));
                    resolve({ status: res.statusCode, data: parsed });
                } catch (e) {
                    console.log('Raw Data:', data);
                    resolve({ status: res.statusCode, data: null });
                }
            });
        });
        req.on('error', (e) => {
            console.error(`Request Error: ${e.message}`);
            resolve({ status: 500, data: null });
        });
        if (body) req.write(JSON.stringify(body));
        req.end();
    });
}

async function runCheck() {
    console.log('--- DIAGNOSING SYSTEM ---');
    const auth = await request('POST', '/auth/login', { email: USER_EMAIL, password: USER_PASS, empresaId: EMPRESA_ID });
    if (!auth.data || !auth.data.accessToken) return;
    token = auth.data.accessToken;

    const profile = await request('GET', '/auth/profile');
    if (profile.data && profile.data.sucursales && profile.data.sucursales.length > 0) {
        sucursalId = profile.data.sucursales[0].id;
    }

    await request('GET', '/sucursales');
    await request('GET', '/clientes');
    await request('GET', '/planes');
    await request('GET', '/inventario/productos');
    if (sucursalId) await request('GET', `/inventario/stock/${sucursalId}`);

    console.log('--- DIAGNOSIS DONE ---');
}
runCheck();
