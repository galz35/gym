const axios = require('axios');

async function test() {
    try {
        const res = await axios.post('https://gym-fxzy.onrender.com/auth/login', {
            email: 'test@test.com',
            password: 'test',
            // Missing empresaId
        });
        console.log(res.data);
    } catch (e) {
        console.log('STATUS:', e.response.status);
        console.log('BODY:', JSON.stringify(e.response.data));
    }
}

test();
