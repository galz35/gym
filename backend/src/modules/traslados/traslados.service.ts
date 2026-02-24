import { Injectable, BadRequestException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateTrasladoDto } from './dto/traslado.dto';

@Injectable()
export class TrasladosService {
    constructor(private prisma: PrismaService) { }

    async crear(empresaId: string, usuarioId: string, dto: CreateTrasladoDto) {
        if (dto.sucursalOrigenId === dto.sucursalDestinoId) {
            throw new BadRequestException('Origen y destino deben ser diferentes');
        }

        return this.prisma.$transaction(async (tx) => {
            // 1. Crear Traslado (Estado CREADO)
            const traslado = await tx.trasladoInventario.create({
                data: {
                    empresa: { connect: { id: empresaId } },
                    sucursal_origen: { connect: { id: dto.sucursalOrigenId } },
                    sucursal_destino: { connect: { id: dto.sucursalDestinoId } },
                    usuario_crea: { connect: { id: usuarioId } },
                    estado: 'CREADO',
                    detalles: {
                        create: dto.detalles.map(d => ({
                            producto: { connect: { id: d.productoId } },
                            cantidad: d.cantidad,
                        }))
                    }
                },
                include: { detalles: true }
            });

            // 2. Decrementar Stock en Origen
            for (const det of dto.detalles) {
                const updated = await tx.inventarioSucursal.updateMany({
                    where: {
                        sucursal_id: dto.sucursalOrigenId,
                        producto_id: det.productoId,
                        existencia: { gte: det.cantidad }
                    },
                    data: {
                        existencia: { decrement: det.cantidad },
                        actualizado_at: new Date()
                    }
                });

                if (updated.count === 0) {
                    throw new ConflictException(`Stock insuficiente en origen para producto ${det.productoId}`);
                }

                // Movimiento Salida (Traslado)
                await tx.movimientoInventario.create({
                    data: {
                        empresa: { connect: { id: empresaId } },
                        sucursal: { connect: { id: dto.sucursalOrigenId } },
                        producto: { connect: { id: det.productoId } },
                        usuario: { connect: { id: usuarioId } },
                        tipo: 'TRASLADO_SALIDA',
                        cantidad: det.cantidad,
                        ref_tipo: 'TRASLADO',
                        ref_id: traslado.id
                    }
                });
            }

            return traslado;
        });
    }

    async recibir(trasladoId: string, usuarioId: string) {
        return this.prisma.$transaction(async (tx) => {
            // 0. Bloqueo Transaccional Optimista (Atomic State Transition)
            const updatedCount = await tx.trasladoInventario.updateMany({
                where: { id: trasladoId, estado: 'CREADO' },
                data: {
                    estado: 'RECIBIDO',
                    recibido_por: usuarioId,
                    recibido_at: new Date()
                }
            });

            if (updatedCount.count === 0) {
                throw new BadRequestException('Traslado no válido para recepción o ya fue recibido previamente');
            }

            const traslado = await tx.trasladoInventario.findUnique({
                where: { id: trasladoId },
                include: { detalles: true }
            });

            if (!traslado) {
                throw new BadRequestException('Error al recuperar detalles del traslado');
            }

            // 1. Aumentar Stock en Destino
            for (const det of traslado.detalles) {
                await tx.inventarioSucursal.upsert({
                    where: {
                        sucursal_id_producto_id: {
                            sucursal_id: traslado.sucursal_destino_id,
                            producto_id: det.producto_id
                        }
                    },
                    update: { existencia: { increment: det.cantidad }, actualizado_at: new Date() },
                    create: {
                        empresa_id: traslado.empresa_id,
                        sucursal_id: traslado.sucursal_destino_id,
                        producto_id: det.producto_id,
                        existencia: det.cantidad,
                    }
                });

                // Movimiento Entrada (Traslado)
                await tx.movimientoInventario.create({
                    data: {
                        empresa_id: traslado.empresa_id,
                        sucursal_id: traslado.sucursal_destino_id,
                        producto_id: det.producto_id,
                        usuario_id: usuarioId,
                        tipo: 'TRASLADO_ENTRADA',
                        cantidad: det.cantidad,
                        ref_tipo: 'TRASLADO',
                        ref_id: traslado.id
                    }
                });
            }

            // 2. Retornar el traslado (ya fue marcado como RECIBIDO en el paso 0)
            return traslado;
        });
    }

    async findAllPendientes(empresaId: string, sucursalDestinoId: string) {
        return this.prisma.trasladoInventario.findMany({
            where: {
                empresa_id: empresaId,
                sucursal_destino_id: sucursalDestinoId,
                estado: 'CREADO'
            },
            include: {
                sucursal_origen: { select: { nombre: true } },
                usuario_crea: { select: { nombre: true } },
                detalles: { include: { producto: { select: { nombre: true } } } }
            }
        });
    }
}
