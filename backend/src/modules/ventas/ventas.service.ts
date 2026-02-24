import { Injectable, BadRequestException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class VentasService {
    constructor(private prisma: PrismaService) { }

    // Lógica crítica 5.4 Venta (POS) + Inventario (transacción segura)
    async createVenta(empresaId: string, sucursalId: string, usuarioId: string, payload: any) {
        /*
          Payload esperado:
          {
            cajaId: uuid,
            clienteId: uuid,
            totalCentavos: number,
            detalles: [ { productoId, cantidad, precioUnit, subtotal } ],
            pagos: [ { monto, metodo, referencia } ] (opcional)
          }
        */
        const { cajaId, clienteId, totalCentavos, detalles, pagos } = payload;

        return this.prisma.$transaction(async (tx) => {
            // 1. Validar caja abierta (OPCIONAL AHORA)
            if (cajaId) {
                const caja = await tx.caja.findUnique({ where: { id: cajaId } });
                if (!caja || caja.estado !== 'ABIERTA') {
                    throw new BadRequestException('La caja proporcionada no está abierta o no existe');
                }
            }

            const ventaData: any = {
                empresa: { connect: { id: empresaId } },
                sucursal: { connect: { id: sucursalId } },
                total_centavos: BigInt(totalCentavos),
                estado: 'APLICADA',
                creado_at: new Date(),
            };
            if (cajaId) ventaData.caja = { connect: { id: cajaId } };
            if (clienteId) ventaData.cliente = { connect: { id: clienteId } };

            // 2. Crear Venta
            const venta = await tx.venta.create({
                data: ventaData,
            });

            // 3. Procesar detalles e inventario
            for (const det of detalles) {
                // Lock inventario & check stock
                // Prisma no tiene "FOR UPDATE" nativo simple en findUnique, usamos queryRaw si es crítico, 
                // pero updateMany con condición where es atómico.

                // Decrementamos stock solo si es suficiente
                const updateResult = await tx.inventarioSucursal.updateMany({
                    where: {
                        sucursal_id: sucursalId,
                        producto_id: det.productoId,
                        existencia: { gte: det.cantidad }, // Condición de stock
                    },
                    data: {
                        existencia: { decrement: det.cantidad },
                        actualizado_at: new Date(),
                    },
                });

                if (updateResult.count === 0) {
                    throw new ConflictException(`Stock insuficiente para producto ${det.productoId}`);
                }

                // Crear detalle venta
                await tx.ventaDetalle.create({
                    data: {
                        venta: { connect: { id: venta.id } },
                        producto: { connect: { id: det.productoId } },
                        cantidad: det.cantidad,
                        precio_unit_centavos: BigInt(det.precioUnit),
                        subtotal_centavos: BigInt(det.subtotal),
                    },
                });

                // Registrar movimiento inventario
                await tx.movimientoInventario.create({
                    data: {
                        empresa: { connect: { id: empresaId } },
                        sucursal: { connect: { id: sucursalId } },
                        producto: { connect: { id: det.productoId } },
                        usuario: { connect: { id: usuarioId } },
                        tipo: 'SALIDA',
                        cantidad: det.cantidad,
                        ref_tipo: 'VENTA',
                        ref_id: venta.id,
                        creado_at: new Date(),
                    },
                });
            }

            // 4. Registrar Pagos (si vienen)
            if (pagos && pagos.length > 0) {
                for (const p of pagos) {
                    const pagoData: any = {
                        empresa: { connect: { id: empresaId } },
                        sucursal: { connect: { id: sucursalId } },
                        tipo: 'PRODUCTO',
                        referencia_id: venta.id,
                        monto_centavos: BigInt(p.monto),
                        metodo: p.metodo,
                        referencia: p.referencia,
                        estado: 'APLICADO',
                        creado_at: new Date(),
                    };
                    if (cajaId) pagoData.caja = { connect: { id: cajaId } };
                    if (clienteId) pagoData.cliente = { connect: { id: clienteId } };

                    await tx.pago.create({
                        data: pagoData,
                    });
                }
            }

            return venta;
        }, { maxWait: 5000, timeout: 15000 });
    }
}
