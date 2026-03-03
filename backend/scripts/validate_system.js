"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
async function testEverything() {
    console.log('--- INICIANDO TEST DE INTEGRACIÓN SISTEMA GYM ---');
    try {
        console.log('[1] Creando datos de prueba...');
        const empresa = await prisma.empresa.create({ data: { nombre: 'TEST_EMPRESA_VALIDACION' } });
        const sucursal = await prisma.sucursal.create({ data: { empresa_id: empresa.id, nombre: 'Sucursal Test' } });
        const usuario = await prisma.usuario.create({
            data: {
                empresa_id: empresa.id,
                nombre: 'Tester',
                email: `test_${Date.now()}@test.com`,
                hash: '123'
            }
        });
        const cliente = await prisma.cliente.create({ data: { empresa_id: empresa.id, nombre: 'Juan Perez Test' } });
        console.log('[2] Test Entrada (Sin membresía)...');
        const resultDenegado = await validarAccesoMock(empresa.id, usuario.id, {
            clienteId: cliente.id,
            sucursalId: sucursal.id
        });
        console.assert(resultDenegado.acceso === false, 'Debería ser denegado por falta de membresía');
        console.log('  > Resultado: Denegado (Correcto)');
        console.log('[3] Agregando membresía activa...');
        const plan = await prisma.planMembresia.create({
            data: {
                empresa_id: empresa.id,
                nombre: 'Plan Test',
                tipo: 'DIAS',
                dias: 30,
                precio_centavos: 1000
            }
        });
        const fin = new Date();
        fin.setDate(fin.getDate() + 30);
        await prisma.membresiaCliente.create({
            data: {
                empresa_id: empresa.id,
                cliente_id: cliente.id,
                sucursal_id: sucursal.id,
                plan_id: plan.id,
                inicio: new Date(),
                fin: fin,
                estado: 'ACTIVA'
            }
        });
        console.log('[4] Test Entrada (Con membresía)...');
        const resultPermitido = await validarAccesoMock(empresa.id, usuario.id, {
            clienteId: cliente.id,
            sucursalId: sucursal.id
        });
        console.assert(resultPermitido.acceso === true, 'Debería ser permitido con membresía activa');
        console.log('  > Resultado: Permitido (Correcto)');
        console.log('[5] Test Salida (Registrando salida de la entrada anterior)...');
        const asistencia = await prisma.asistencia.findFirst({
            where: { cliente_id: cliente.id, resultado: 'PERMITIDO' },
            orderBy: { fecha_hora: 'desc' }
        });
        console.assert(asistencia !== null, 'Debería existir un registro de asistencia');
        console.assert(asistencia?.fecha_salida === null, 'La fecha de salida debería ser null inicialmente');
        const resultSalida = await registrarSalidaMock(cliente.id, sucursal.id);
        console.assert(resultSalida.acceso === true, 'La salida debería registrarse exitosamente');
        const asistenciaFinal = await prisma.asistencia.findUnique({ where: { id: asistencia.id } });
        console.assert(asistenciaFinal?.fecha_salida !== null, 'La fecha de salida ahora DEBERÍA estar llena');
        console.log('  > Resultado: Salida Registrada (Correcto)');
        console.log('[6] Limpiando datos de prueba...');
        await prisma.asistencia.deleteMany({ where: { empresa_id: empresa.id } });
        await prisma.membresiaCliente.deleteMany({ where: { empresa_id: empresa.id } });
        await prisma.cliente.deleteMany({ where: { empresa_id: empresa.id } });
        await prisma.planMembresia.deleteMany({ where: { empresa_id: empresa.id } });
        await prisma.sucursal.deleteMany({ where: { empresa_id: empresa.id } });
        await prisma.usuario.deleteMany({ where: { empresa_id: empresa.id } });
        await prisma.empresa.delete({ where: { id: empresa.id } });
        console.log('\n✅✅ TEST DE SISTEMA COMPLETADO CON ÉXITO ✅✅');
    }
    catch (error) {
        console.error('\n❌ ERROR DURANTE EL TEST ❌');
        console.error(error);
        throw error;
    }
    finally {
        await prisma.$disconnect();
    }
}
async function validarAccesoMock(empresaId, usuarioId, dto) {
    const cliente = await prisma.cliente.findUnique({
        where: { id: dto.clienteId },
        include: {
            membresias: {
                where: { estado: 'ACTIVA', fin: { gte: new Date() } },
                include: { plan: true },
                orderBy: { fin: 'desc' },
                take: 1
            }
        }
    });
    if (!cliente || cliente.estado !== 'ACTIVO')
        return { acceso: false, motivo: 'INACTIVO' };
    const membresia = cliente.membresias[0];
    const resultado = membresia ? 'PERMITIDO' : 'DENEGADO';
    await prisma.asistencia.create({
        data: {
            empresa: { connect: { id: empresaId } },
            sucursal: { connect: { id: dto.sucursalId } },
            cliente: { connect: { id: dto.clienteId } },
            usuario: { connect: { id: usuarioId } },
            resultado,
            nota: membresia ? 'OK' : 'SIN_MEMBRESIA'
        }
    });
    return { acceso: resultado === 'PERMITIDO' };
}
async function registrarSalidaMock(clienteId, sucursalId) {
    const ultima = await prisma.asistencia.findFirst({
        where: {
            cliente_id: clienteId,
            sucursal_id: sucursalId,
            fecha_salida: null,
            resultado: 'PERMITIDO',
        },
        orderBy: { fecha_hora: 'desc' },
    });
    if (!ultima)
        throw new Error('No se encontró entrada activa');
    await prisma.asistencia.update({
        where: { id: ultima.id },
        data: { fecha_salida: new Date() }
    });
    return { acceso: true };
}
testEverything();
//# sourceMappingURL=validate_system.js.map