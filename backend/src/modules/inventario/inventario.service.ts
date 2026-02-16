import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateEntradaDto, CreateProductoDto } from './dto/inventario.dto';

@Injectable()
export class InventarioService {
    constructor(private prisma: PrismaService) { }

    async findAllProductos(empresaId: string) {
        return this.prisma.producto.findMany({
            where: { empresa_id: empresaId, estado: 'ACTIVO' },
            include: {
                inventarios: true // Para ver stock por sucursal
            }
        });
    }

    async findStockSucursal(sucursalId: string) {
        return this.prisma.inventarioSucursal.findMany({
            where: { sucursal_id: sucursalId },
            include: { producto: true }
        });
    }

    async createProducto(empresaId: string, dto: CreateProductoDto) {
        return this.prisma.producto.create({
            data: {
                empresa: { connect: { id: empresaId } },
                nombre: dto.nombre,
                categoria: dto.categoria,
                precio_centavos: BigInt(Math.round(dto.precio * 100)),
                costo_centavos: BigInt(Math.round(dto.costo * 100)),
                estado: 'ACTIVO',
            },
        });
    }

    async registrarEntrada(empresaId: string, usuarioId: string, dto: CreateEntradaDto) {
        // Transacción: Aumentar stock y registrar movimiento
        return this.prisma.$transaction(async (tx) => {
            // Upsert inventario
            await tx.inventarioSucursal.upsert({
                where: { sucursal_id_producto_id: { sucursal_id: dto.sucursalId, producto_id: dto.productoId } },
                update: { existencia: { increment: dto.cantidad }, actualizado_at: new Date() },
                create: {
                    empresa: { connect: { id: empresaId } },
                    sucursal: { connect: { id: dto.sucursalId } },
                    producto: { connect: { id: dto.productoId } },
                    existencia: dto.cantidad
                }
            });

            // Crear Movimiento
            return tx.movimientoInventario.create({
                data: {
                    empresa: { connect: { id: empresaId } },
                    sucursal: { connect: { id: dto.sucursalId } },
                    producto: { connect: { id: dto.productoId } },
                    usuario: { connect: { id: usuarioId } },
                    tipo: 'ENTRADA',
                    cantidad: dto.cantidad,
                    ref_tipo: 'ABASTECIMIENTO',
                    payload_json: dto.notas ? { notas: dto.notas } : {},
                }
            });
        });
    }
    async getTopProductos(empresaId: string, sucursalId: string) {
        // Top 20 productos más vendidos en últimos 30 días
        const fechaInicio = new Date();
        fechaInicio.setDate(fechaInicio.getDate() - 30);

        const top = await this.prisma.ventaDetalle.groupBy({
            by: ['producto_id'],
            where: {
                venta: {
                    empresa_id: empresaId,
                    sucursal_id: sucursalId,
                    creado_at: { gte: fechaInicio }
                }
            },
            _sum: { cantidad: true },
            orderBy: { _sum: { cantidad: 'desc' } },
            take: 20
        });

        const productIds = top.map(t => t.producto_id);
        const productos = await this.prisma.producto.findMany({
            where: { id: { in: productIds } }
        });

        // Mapear resultado
        return top.map(t => {
            const p = productos.find(prod => prod.id === t.producto_id);
            return {
                ...p, // precio_centavos es BigInt, cuidado al serializar
                ventas_periodo: Number(t._sum.cantidad || 0)
            };
        });
    }
}
