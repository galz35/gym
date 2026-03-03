"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
async function cleanTestData() {
    console.log('--- INICIANDO LIMPIEZA DE DATOS DE PRUEBA ---');
    try {
        console.log('Limpiando KPIs, Logs y Bitácoras...');
        await prisma.kpiDiarioSucursal.deleteMany();
        await prisma.cambioLog.deleteMany();
        await prisma.bitacora.deleteMany();
        await prisma.eventoProcesado.deleteMany();
        await prisma.syncRequestProcesado.deleteMany();
        console.log('Limpiando Ventas y Pagos...');
        await prisma.ventaDetalle.deleteMany();
        await prisma.venta.deleteMany();
        await prisma.pago.deleteMany();
        console.log('Limpiando Inventario y Productos...');
        await prisma.movimientoInventario.deleteMany();
        await prisma.trasladoInventarioDet.deleteMany();
        await prisma.trasladoInventario.deleteMany();
        await prisma.inventarioSucursal.deleteMany();
        await prisma.producto.deleteMany();
        console.log('Limpiando Clientes, Membresías y Asistencias...');
        await prisma.asistencia.deleteMany();
        await prisma.membresiaCliente.deleteMany();
        await prisma.cliente.deleteMany();
        await prisma.planMembresia.deleteMany();
        console.log('Limpiando Cajas y Tokens...');
        await prisma.caja.deleteMany();
        await prisma.refreshToken.deleteMany();
        console.log('--- LIMPIEZA COMPLETADA CON ÉXITO ---');
        console.log('Se han conservado: Empresas, Sucursales, Usuarios y Roles.');
    }
    catch (error) {
        console.error('Error durante la limpieza de datos:', error);
    }
    finally {
        await prisma.$disconnect();
    }
}
cleanTestData();
//# sourceMappingURL=clean_test_data.js.map