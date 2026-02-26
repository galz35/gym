import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

async function main() {
    const prisma = new PrismaClient();
    const email = 'admin@gympro.com';
    const newPass = '123456';

    try {
        const user = await prisma.usuario.findFirst({
            where: { email: email }
        });

        if (!user) {
            console.log(`User ${email} not found`);
            return;
        }

        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(newPass, salt);

        await prisma.usuario.update({
            where: { id: user.id },
            data: { hash: hash }
        });

        console.log(`PASSWORD_UPDATED: Successfully updated password for ${email} to ${newPass}`);
        console.log(`EMPRESA_ID: ${user.empresa_id}`);

    } catch (error) {
        console.error('ERROR:', error);
    } finally {
        await prisma.$disconnect();
    }
}

main();
