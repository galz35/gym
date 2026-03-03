"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
async function runScenario() {
    console.log('--- INICIANDO SIMULACIÓN DE 30 DÍAS ---');
    console.log('[0] Limpiando datos de simulaciones anteriores...');
    const empresasSim = await prisma.empresa.findMany({ where: { nombre: { startsWith: 'SIM_' } } });
    for (const e of empresasSim) {
        await prisma.asistencia.deleteMany({ where: { empresa_id: e.id } });
        await prisma.membresiaCliente.deleteMany({ where: { empresa_id: e.id } });
        await prisma.movimientoInventario.deleteMany({ where: { empresa_id: e.id } });
        await prisma.trasladoInventarioDet.deleteMany({ where: { traslado: { empresa_id: e.id } } });
        await prisma.trasladoInventario.deleteMany({ where: { empresa_id: e.id } });
        await prisma.inventarioSucursal.deleteMany({ where: { empresa_id: e.id } });
        await prisma.ventaDetalle.deleteMany({ where: { venta: { empresa_id: e.id } } });
        await prisma.venta.deleteMany({ where: { empresa_id: e.id } });
        await prisma.pago.deleteMany({ where: { empresa_id: e.id } });
        await prisma.cliente.deleteMany({ where: { empresa_id: e.id } });
        await prisma.planMembresia.deleteMany({ where: { empresa_id: e.id } });
        await prisma.producto.deleteMany({ where: { empresa_id: e.id } });
        await prisma.caja.deleteMany({ where: { empresa_id: e.id } });
        await prisma.kpiDiarioSucursal.deleteMany({ where: { empresa_id: e.id } });
        await prisma.cambioLog.deleteMany({ where: { empresa_id: e.id } });
        await prisma.usuarioSucursal.deleteMany({ where: { sucursal: { empresa_id: e.id } } });
        await prisma.sucursal.deleteMany({ where: { empresa_id: e.id } });
        await prisma.usuario.deleteMany({ where: { empresa_id: e.id } });
    }
    await prisma.empresa.deleteMany({ where: { nombre: { startsWith: 'SIM_' } } });
    console.log('[1] SETUP INICIAL DE DATOS:');
    const empresa = await prisma.empresa.create({ data: { nombre: 'SIM_Gym 30 Dias' } });
    const usuario = await prisma.usuario.create({
        data: {
            empresa_id: empresa.id,
            nombre: 'Admin Simulación',
            email: 'admin_sim30@gym.com',
            hash: 'hash123'
        }
    });
    const sucursalA = await prisma.sucursal.create({ data: { empresa_id: empresa.id, nombre: 'Sucursal A (Principal)' } });
    const sucursalB = await prisma.sucursal.create({ data: { empresa_id: empresa.id, nombre: 'Sucursal B (Norte)' } });
    const caja = await prisma.caja.create({
        data: {
            empresa_id: empresa.id,
            sucursal_id: sucursalA.id,
            usuario_id: usuario.id,
            monto_apertura_centavos: 100000,
            estado: 'ABIERTA'
        }
    });
    const planDia = await prisma.planMembresia.create({ data: { empresa_id: empresa.id, nombre: 'Pase de Día', tipo: 'DIAS', dias: 1, precio_centavos: 3000 } });
    const planSemana = await prisma.planMembresia.create({ data: { empresa_id: empresa.id, nombre: 'Pase Semanal', tipo: 'DIAS', dias: 7, precio_centavos: 15000 } });
    const planMes = await prisma.planMembresia.create({ data: { empresa_id: empresa.id, nombre: 'Pase Mensual', tipo: 'DIAS', dias: 30, precio_centavos: 50000 } });
    const prodAgua = await prisma.producto.create({
        data: {
            empresa_id: empresa.id,
            nombre: 'Agua Mineral',
            categoria: 'Bebidas',
            precio_centavos: 2000,
            costo_centavos: 1000
        }
    });
    const prodProteina = await prisma.producto.create({
        data: {
            empresa_id: empresa.id,
            nombre: 'Batido Proteína',
            categoria: 'Bebidas',
            precio_centavos: 5000,
            costo_centavos: 2500
        }
    });
    await prisma.inventarioSucursal.create({ data: { empresa_id: empresa.id, sucursal_id: sucursalA.id, producto_id: prodAgua.id, existencia: 100 } });
    await prisma.inventarioSucursal.create({ data: { empresa_id: empresa.id, sucursal_id: sucursalA.id, producto_id: prodProteina.id, existencia: 50 } });
    let clientes = [];
    for (let i = 1; i <= 5; i++) {
        clientes.push(await prisma.cliente.create({ data: { empresa_id: empresa.id, nombre: `Cliente Fijo ${i}`, telefono: `100${i}` } }));
    }
    let stats = {
        asistencias_permitidas: 0,
        asistencias_denegadas: 0,
        nuevos_clientes: 0,
        membresias_vendidas: 0,
        productos_vendidos: 0,
        mermas: 0,
        traslados: 0,
        salidas_registradas: 0,
        ingresos_centavos: BigInt(0)
    };
    const fechaInicio = new Date();
    fechaInicio.setHours(8, 0, 0, 0);
    console.log('\n=======================================');
    console.log('🚀 INICIANDO BUCLE DE 30 DÍAS');
    console.log('=======================================');
    for (let day = 1; day <= 30; day++) {
        const currentDate = new Date(fechaInicio);
        currentDate.setDate(currentDate.getDate() + day);
        console.log(`\n--- DÍA ${day} (${currentDate.toISOString().split('T')[0]}) ---`);
        for (const cliente of clientes) {
            const mems = await prisma.membresiaCliente.findMany({
                where: { cliente_id: cliente.id, sucursal_id: sucursalA.id, estado: 'ACTIVA' }
            });
            const activa = mems.find(m => m.fin > currentDate);
            if (activa) {
                await prisma.asistencia.create({
                    data: {
                        empresa_id: empresa.id, sucursal_id: sucursalA.id, cliente_id: cliente.id, usuario_id: usuario.id,
                        resultado: 'PERMITIDO', nota: 'Acesso Regular', fecha_hora: currentDate
                    }
                });
                stats.asistencias_permitidas++;
            }
            else {
                await prisma.asistencia.create({
                    data: {
                        empresa_id: empresa.id, sucursal_id: sucursalA.id, cliente_id: cliente.id, usuario_id: usuario.id,
                        resultado: 'DENEGADO', nota: 'Membresía Vencida o Inexistente', fecha_hora: currentDate
                    }
                });
                stats.asistencias_denegadas++;
                const fin = new Date(currentDate);
                fin.setDate(fin.getDate() + 30);
                await prisma.membresiaCliente.create({
                    data: {
                        empresa_id: empresa.id, sucursal_id: sucursalA.id, cliente_id: cliente.id, plan_id: planMes.id,
                        inicio: currentDate, fin: fin, estado: 'ACTIVA'
                    }
                });
                stats.membresias_vendidas++;
                stats.ingresos_centavos += BigInt(planMes.precio_centavos);
                await prisma.asistencia.create({
                    data: {
                        empresa_id: empresa.id, sucursal_id: sucursalA.id, cliente_id: cliente.id, usuario_id: usuario.id,
                        resultado: 'PERMITIDO', nota: 'Acceso Post-Renovación', fecha_hora: currentDate
                    }
                });
                stats.asistencias_permitidas++;
                const fechaSalida = new Date(currentDate);
                fechaSalida.setHours(fechaSalida.getHours() + 1.5);
                await prisma.asistencia.updateMany({
                    where: {
                        cliente_id: cliente.id,
                        sucursal_id: sucursalA.id,
                        fecha_salida: null,
                        resultado: 'PERMITIDO'
                    },
                    data: { fecha_salida: fechaSalida }
                });
                stats.salidas_registradas++;
            }
        }
        if (day % 3 === 0) {
            const nuevoCliente = await prisma.cliente.create({ data: { empresa_id: empresa.id, nombre: `Cliente Nuevo D${day}`, telefono: `900${day}` } });
            clientes.push(nuevoCliente);
            stats.nuevos_clientes++;
            const fin = new Date(currentDate);
            fin.setDate(fin.getDate() + 7);
            await prisma.membresiaCliente.create({
                data: {
                    empresa_id: empresa.id, sucursal_id: sucursalA.id, cliente_id: nuevoCliente.id, plan_id: planSemana.id,
                    inicio: currentDate, fin: fin, estado: 'ACTIVA'
                }
            });
            stats.membresias_vendidas++;
            stats.ingresos_centavos += BigInt(planSemana.precio_centavos);
            console.log(`  [Nuevo Cliente] ${nuevoCliente.nombre} se unió y compró Pase Semanal.`);
        }
        const venta = await prisma.venta.create({
            data: {
                empresa_id: empresa.id, sucursal_id: sucursalA.id, caja_id: caja.id, cliente_id: clientes[0].id,
                total_centavos: (prodAgua.precio_centavos * BigInt(2)) + prodProteina.precio_centavos, estado: 'APLICADA', creado_at: currentDate
            }
        });
        await prisma.ventaDetalle.createMany({
            data: [
                { venta_id: venta.id, producto_id: prodAgua.id, cantidad: 2, precio_unit_centavos: Number(prodAgua.precio_centavos), subtotal_centavos: Number(prodAgua.precio_centavos) * 2 },
                { venta_id: venta.id, producto_id: prodProteina.id, cantidad: 1, precio_unit_centavos: Number(prodProteina.precio_centavos), subtotal_centavos: Number(prodProteina.precio_centavos) }
            ]
        });
        stats.ingresos_centavos += BigInt(venta.total_centavos);
        stats.productos_vendidos += 3;
        await prisma.inventarioSucursal.update({ where: { sucursal_id_producto_id: { sucursal_id: sucursalA.id, producto_id: prodAgua.id } }, data: { existencia: { decrement: 2 } } });
        await prisma.inventarioSucursal.update({ where: { sucursal_id_producto_id: { sucursal_id: sucursalA.id, producto_id: prodProteina.id } }, data: { existencia: { decrement: 1 } } });
        await prisma.movimientoInventario.createMany({
            data: [
                { empresa_id: empresa.id, sucursal_id: sucursalA.id, producto_id: prodAgua.id, usuario_id: usuario.id, tipo: 'SALIDA', cantidad: 2, ref_tipo: 'VENTA', ref_id: venta.id, creado_at: currentDate },
                { empresa_id: empresa.id, sucursal_id: sucursalA.id, producto_id: prodProteina.id, usuario_id: usuario.id, tipo: 'SALIDA', cantidad: 1, ref_tipo: 'VENTA', ref_id: venta.id, creado_at: currentDate }
            ]
        });
        if (day % 10 === 0) {
            await prisma.inventarioSucursal.update({ where: { sucursal_id_producto_id: { sucursal_id: sucursalA.id, producto_id: prodAgua.id } }, data: { existencia: { decrement: 1 } } });
            await prisma.movimientoInventario.create({ data: { empresa_id: empresa.id, sucursal_id: sucursalA.id, producto_id: prodAgua.id, usuario_id: usuario.id, tipo: 'SALIDA', cantidad: 1, ref_tipo: 'MERMA', payload_json: { notas: 'Dañado' }, creado_at: currentDate } });
            stats.mermas++;
            console.log(`  [Merma] Reportada 1 botella de agua dañada.`);
        }
        if (day === 15) {
            const traslado = await prisma.trasladoInventario.create({
                data: { empresa_id: empresa.id, sucursal_origen_id: sucursalA.id, sucursal_destino_id: sucursalB.id, creado_por: usuario.id, estado: 'RECIBIDO', creado_at: currentDate }
            });
            await prisma.trasladoInventarioDet.create({ data: { traslado_id: traslado.id, producto_id: prodAgua.id, cantidad: 20 } });
            await prisma.inventarioSucursal.update({ where: { sucursal_id_producto_id: { sucursal_id: sucursalA.id, producto_id: prodAgua.id } }, data: { existencia: { decrement: 20 } } });
            await prisma.inventarioSucursal.upsert({ where: { sucursal_id_producto_id: { sucursal_id: sucursalB.id, producto_id: prodAgua.id } }, update: { existencia: { increment: 20 } }, create: { empresa_id: empresa.id, sucursal_id: sucursalB.id, producto_id: prodAgua.id, existencia: 20 } });
            await prisma.movimientoInventario.createMany({
                data: [
                    { empresa_id: empresa.id, sucursal_id: sucursalA.id, producto_id: prodAgua.id, usuario_id: usuario.id, tipo: 'SALIDA', cantidad: 20, ref_tipo: 'TRASLADO_OUT', ref_id: traslado.id, creado_at: currentDate },
                    { empresa_id: empresa.id, sucursal_id: sucursalB.id, producto_id: prodAgua.id, usuario_id: usuario.id, tipo: 'ENTRADA', cantidad: 20, ref_tipo: 'TRASLADO_IN', ref_id: traslado.id, creado_at: currentDate }
                ]
            });
            stats.traslados++;
            console.log(`  [Traslado] 20 bidones de agua enviados a Sucursal B.`);
        }
        console.log(`  > Total Clientes Activos: ${clientes.length} | Asist. Totales (Permitidas + Denegadas): ${clientes.length + (clientes.some(c => !c) ? 1 : 0)}`);
    }
    console.log('\n=======================================');
    console.log('📊 RESULTADOS TRAS 30 DÍAS DE OPERACIÓN');
    console.log('=======================================');
    console.log(`- Nuevos Clientes Captados: ${stats.nuevos_clientes}`);
    console.log(`- Total Asistencias Permitidas: ${stats.asistencias_permitidas}`);
    console.log(`- Total Salidas Registradas: ${stats.salidas_registradas}`);
    console.log(`- Total Accesos Denegados (Filtro/Renovación): ${stats.asistencias_denegadas}`);
    console.log(`- Membresías Vendidas/Renovadas: ${stats.membresias_vendidas}`);
    console.log(`- Productos de POS Vendidos: ${stats.productos_vendidos}`);
    console.log(`- Eventos de Merma: ${stats.mermas}`);
    console.log(`- Traslados Efectuados: ${stats.traslados}`);
    console.log(`- Ingresos Brutos (Centavos): C$ ${stats.ingresos_centavos.toString() / 100}`);
    const stockAguaFinal = await prisma.inventarioSucursal.findUnique({ where: { sucursal_id_producto_id: { sucursal_id: sucursalA.id, producto_id: prodAgua.id } } });
    const stockProteinaFinal = await prisma.inventarioSucursal.findUnique({ where: { sucursal_id_producto_id: { sucursal_id: sucursalA.id, producto_id: prodProteina.id } } });
    console.log('\n📦 INVENTARIO FINAL EN SUCURSAL A');
    console.log(`- Agua Mineral: ${stockAguaFinal?.existencia} unidades (Esperado: 100 base - (2 x 30 días) - (3 mermas) - (20 traslado) = 17)`);
    console.assert(Number(stockAguaFinal?.existencia) === 17, 'Fallo en stock agua final!');
    console.log(`- Batido Proteína: ${stockProteinaFinal?.existencia} unidades (Esperado: 50 base - (1 x 30 días) = 20)`);
    console.assert(Number(stockProteinaFinal?.existencia) === 20, 'Fallo en stock proteina final!');
    console.log('\n✅✅ LA SIMULACIÓN DE 30 DÍAS COMPLETÓ Y CUADRÓ EXITOSAMENTE ✅✅');
    await prisma.$disconnect();
}
runScenario().catch(e => {
    console.error(e);
});
//# sourceMappingURL=simulate_month.js.map