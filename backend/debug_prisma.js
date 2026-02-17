const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient({
    log: ['query', 'info', 'warn', 'error'],
});

async function main() {
    try {
        console.log('Testing connection...');
        const result = await prisma.$queryRaw`SELECT 1 as result`;
        console.log('Connection OK:', result);

        console.log('Testing schema access (gym.usuario)...');
        const users = await prisma.usuario.findMany({ take: 1 });
        console.log('Users found:', users.length);
    } catch (e) {
        console.error('CRITICAL ERROR:', e);
    } finally {
        await prisma.$disconnect();
    }
}

main();
