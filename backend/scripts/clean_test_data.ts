import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function cleanTestData() {
    console.log('--- INICIANDO LIMPIEZA DE DATOS DE PRUEBA ---');

    try {
        // 1. Eliminar datos transaccionales y de logs primero (debido a FKs)
        console.log('Limpiando KPIs, Logs y Bitácoras...');
        await prisma.kpiDiarioSucursal.deleteMany();
        await prisma.cambioLog.deleteMany();
        await prisma.bitacora.deleteMany();
        await prisma.eventoProcesado.deleteMany();
        await prisma.syncRequestProcesado.deleteMany();

        // 2. Transacciones y Ventas
        console.log('Limpiando Ventas y Pagos...');
        await prisma.ventaDetalle.deleteMany();
        await prisma.venta.deleteMany();
        await prisma.pago.deleteMany();

        // 3. Inventario y Productos
        console.log('Limpiando Inventario y Productos...');
        await prisma.movimientoInventario.deleteMany();
        await prisma.trasladoInventarioDet.deleteMany();
        await prisma.trasladoInventario.deleteMany();
        await prisma.inventarioSucursal.deleteMany();
        await prisma.producto.deleteMany();

        // 4. Clientes y Membresías
        console.log('Limpiando Clientes, Membresías y Asistencias...');
        await prisma.asistencia.deleteMany();
        await prisma.membresiaCliente.deleteMany();
        await prisma.cliente.deleteMany();
        await prisma.planMembresia.deleteMany();

        // 5. Cajas y Sesiones
        console.log('Limpiando Cajas y Tokens...');
        await prisma.caja.deleteMany();
        await prisma.refreshToken.deleteMany();

        console.log('--- LIMPIEZA COMPLETADA CON ÉXITO ---');
        console.log('Se han conservado: Empresas, Sucursales, Usuarios y Roles.');
    } catch (error) {
        console.error('Error durante la limpieza de datos:', error);
    } finally {
        await prisma.$disconnect();
    }
}

cleanTestData();
