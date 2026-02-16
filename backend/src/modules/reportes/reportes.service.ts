import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class ReportesService {
    constructor(private prisma: PrismaService) { }

    async getResumenDia(empresaId: string, sucursalId: string, fecha: Date) {
        // Definir rango del día
        const inicio = new Date(fecha.setHours(0, 0, 0, 0));
        const fin = new Date(fecha.setHours(23, 59, 59, 999));

        // Consultas paralelas para dashboard
        const [asistencias, ventas, pagos, nuevosClientes] = await Promise.all([
            this.prisma.asistencia.count({
                where: { empresa_id: empresaId, sucursal_id: sucursalId, fecha_hora: { gte: inicio, lte: fin } },
            }),
            this.prisma.venta.aggregate({
                where: { empresa_id: empresaId, sucursal_id: sucursalId, creado_at: { gte: inicio, lte: fin }, estado: 'APLICADA' },
                _sum: { total_centavos: true },
                _count: true,
            }),
            this.prisma.pago.aggregate({
                where: { empresa_id: empresaId, sucursal_id: sucursalId, creado_at: { gte: inicio, lte: fin }, estado: 'APLICADO' },
                _sum: { monto_centavos: true },
            }),
            this.prisma.cliente.count({
                where: { empresa_id: empresaId, creado_at: { gte: inicio, lte: fin } },
            }),
        ]);

        return {
            fecha: inicio.toISOString(),
            asistencias,
            ventas: {
                cantidad: ventas._count,
                total: Number(ventas._sum.total_centavos || 0) / 100, // Retornar en moneda real para fácil consumo
            },
            ingresos: Number(pagos._sum.monto_centavos || 0) / 100,
            nuevosClientes,
        };
    }

    async getVencimientos(empresaId: string, sucursalId: string, diasProximos: number) {
        const hoy = new Date();
        const limite = new Date();
        limite.setDate(hoy.getDate() + diasProximos);

        return this.prisma.membresiaCliente.findMany({
            where: {
                empresa_id: empresaId,
                sucursal_id: sucursalId,
                fin: { gte: hoy, lte: limite },
                estado: 'ACTIVA',
            },
            include: {
                cliente: { select: { nombre: true, foto_url: true } }, // Incluir foto
                plan: { select: { nombre: true } },
            },
            orderBy: { fin: 'asc' },
        });
    }

    async getVentasRango(empresaId: string, sucursalId: string, desde: Date, hasta: Date) {
        return this.prisma.venta.findMany({
            where: {
                empresa_id: empresaId,
                sucursal_id: sucursalId,
                creado_at: { gte: desde, lte: hasta },
                estado: 'APLICADA'
            },
            include: {
                cliente: { select: { nombre: true } },
                detalles: { include: { producto: true } }
            },
            orderBy: { creado_at: 'desc' }
        });
    }

    async getAsistenciaPorHora(empresaId: string, sucursalId: string, fecha: Date) {
        const inicio = new Date(fecha);
        inicio.setHours(0, 0, 0, 0);
        const fin = new Date(fecha);
        fin.setHours(23, 59, 59, 999);

        // Raw Query en esquema gym
        const resultados: any[] = await this.prisma.$queryRaw`
            SELECT EXTRACT(HOUR FROM fecha_hora) as hora, COUNT(*)::integer as cantidad
            FROM gym.asistencia
            WHERE empresa_id = ${empresaId}::uuid
            AND sucursal_id = ${sucursalId}::uuid
            AND fecha_hora >= ${inicio} AND fecha_hora <= ${fin}
            GROUP BY hora
            ORDER BY hora ASC
        `;

        return resultados.map(r => ({
            hora: Number(r.hora),
            cantidad: Number(r.cantidad)
        }));
    }
}
