const https = require('https');
const http = require('http');

const urls = [
    'https://www.rhclaroni.com/apig/health/ping',
    'http://190.56.16.85/apig/health/ping'
];

async function testUrl(url) {
    console.log(`\nTesting: ${url}`);
    const client = url.startsWith('https') ? https : http;

    return new Promise((resolve) => {
        client.get(url, (res) => {
            let data = '';
            res.on('data', (chunk) => { data += chunk; });
            res.on('end', () => {
                console.log(`Status: ${res.statusCode}`);
                console.log(`Content Type: ${res.headers['content-type']}`);
                try {
                    const json = JSON.parse(data);
                    console.log('Response JSON:', JSON.stringify(json, null, 2));
                    if (json.status === 'success' || json.status === 'error') {
                        console.log('✅ API reached (Service responded)');
                    }
                } catch (e) {
                    console.log('Response is not JSON (likely Nginx or Frontend page)');
                    // console.log('Data preview:', data.substring(0, 100));
                }
                resolve();
            });
        }).on('error', (err) => {
            console.log(`❌ Error: ${err.message}`);
            resolve();
        });
    });
}

async function runTests() {
    for (const url of urls) {
        await testUrl(url);
    }
}

runTests();
