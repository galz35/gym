"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
async function main() {
    const empresa = await prisma.empresa.findFirst();
    const sucursal = await prisma.sucursal.findFirst();
    const userAdmin = await prisma.usuario.findFirst();
    if (!empresa || !sucursal || !userAdmin) {
        throw new Error('Faltan datos base (empresa, sucursal, usuario)');
    }
    const empresaId = empresa.id;
    const sucursalId = sucursal.id;
    const cliente = await prisma.cliente.create({
        data: {
            empresa_id: empresaId,
            nombre: 'Juan Perez (Prueba CRM)',
            telefono: '+505 8888 9999',
            email: 'juan.perez.test@gympro.com'
        }
    });
    console.log('Cliente creado:', cliente.nombre);
    const prod1 = await prisma.producto.create({
        data: {
            empresa_id: empresaId,
            nombre: 'Proteina Whey 2lbs (Demo)',
            categoria: 'Suplementos',
            precio_centavos: 250000,
            costo_centavos: 150000,
        }
    });
    const prod2 = await prisma.producto.create({
        data: {
            empresa_id: empresaId,
            nombre: 'Agua Embotellada 500ml',
            categoria: 'Bebidas',
            precio_centavos: 2500,
            costo_centavos: 1000,
        }
    });
    console.log('Productos creados.');
    await prisma.inventarioSucursal.create({
        data: {
            empresa_id: empresaId,
            sucursal_id: sucursalId,
            producto_id: prod1.id,
            existencia: 50
        }
    });
    await prisma.inventarioSucursal.create({
        data: {
            empresa_id: empresaId,
            sucursal_id: sucursalId,
            producto_id: prod2.id,
            existencia: 100
        }
    });
    let plan = await prisma.planMembresia.findFirst({ where: { empresa_id: empresaId } });
    if (!plan) {
        plan = await prisma.planMembresia.create({
            data: {
                empresa_id: empresaId,
                nombre: 'Plan Anual Premium (Demo)',
                tipo: 'DURACION',
                dias: 365,
                precio_centavos: 4500000
            }
        });
    }
    const hace10Dias = new Date();
    hace10Dias.setDate(hace10Dias.getDate() - 10);
    const membresiaFin = new Date(hace10Dias);
    membresiaFin.setFullYear(membresiaFin.getFullYear() + 1);
    await prisma.membresiaCliente.create({
        data: {
            empresa_id: empresaId,
            sucursal_id: sucursalId,
            cliente_id: cliente.id,
            plan_id: plan.id,
            inicio: hace10Dias,
            fin: membresiaFin,
            estado: 'ACTIVA'
        }
    });
    console.log('Membresia asignada.');
    for (let i = 0; i < 7; i++) {
        const asisDate = new Date();
        asisDate.setDate(asisDate.getDate() - i);
        asisDate.setHours(i % 2 === 0 ? 18 : 7, Math.floor(Math.random() * 59), 0);
        await prisma.asistencia.create({
            data: {
                empresa_id: empresaId,
                sucursal_id: sucursalId,
                cliente_id: cliente.id,
                usuario_id: userAdmin.id,
                fecha_hora: asisDate,
                resultado: 'ACCESO_PERMITIDO'
            }
        });
    }
    console.log('Asistencias (Check-ins) generadas.');
    let caja = await prisma.caja.findFirst({ where: { sucursal_id: sucursalId, estado: 'ABIERTA' } });
    if (!caja) {
        caja = await prisma.caja.create({
            data: {
                empresa_id: empresaId,
                sucursal_id: sucursalId,
                usuario_id: userAdmin.id,
                estado: 'ABIERTA',
                monto_apertura_centavos: 50000
            }
        });
    }
    const ventaAyer = new Date();
    ventaAyer.setDate(ventaAyer.getDate() - 1);
    ventaAyer.setHours(15, 30, 0);
    const venta = await prisma.venta.create({
        data: {
            empresa_id: empresaId,
            sucursal_id: sucursalId,
            caja_id: caja.id,
            cliente_id: cliente.id,
            total_centavos: 250000 + 2500,
            estado: 'APLICADA',
            creado_at: ventaAyer
        }
    });
    await prisma.ventaDetalle.createMany({
        data: [
            { venta_id: venta.id, producto_id: prod1.id, cantidad: 1, precio_unit_centavos: 250000, subtotal_centavos: 250000 },
            { venta_id: venta.id, producto_id: prod2.id, cantidad: 1, precio_unit_centavos: 2500, subtotal_centavos: 2500 }
        ]
    });
    await prisma.pago.create({
        data: {
            empresa_id: empresaId,
            sucursal_id: sucursalId,
            caja_id: caja.id,
            cliente_id: cliente.id,
            tipo: 'PRODUCTO',
            referencia_id: venta.id,
            monto_centavos: 252500,
            metodo: 'EFECTIVO',
            estado: 'APLICADO',
            creado_at: ventaAyer
        }
    });
    await prisma.pago.create({
        data: {
            empresa_id: empresaId,
            sucursal_id: sucursalId,
            caja_id: caja.id,
            cliente_id: cliente.id,
            tipo: 'MEMBRESIA',
            monto_centavos: 4500000,
            metodo: 'EFECTIVO',
            estado: 'APLICADO',
            creado_at: ventaAyer
        }
    });
    console.log('Venta POS (Proteina + Agua) y Pago Membresía generada para el día de ayer.');
}
main().catch(console.error).finally(() => prisma.$disconnect());
//# sourceMappingURL=test_data.js.map