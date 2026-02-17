import { Injectable, BadRequestException, PreconditionFailedException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { OpenCajaDto, CloseCajaDto } from './dto/actions-caja.dto';

@Injectable()
export class CajaService {
    constructor(private prisma: PrismaService) { }

    async findAbierta(empresaId: string, sucursalId: string, usuarioId: string) {
        return this.prisma.caja.findFirst({
            where: {
                empresa_id: empresaId,
                sucursal_id: sucursalId,
                usuario_id: usuarioId,
                estado: 'ABIERTA',
            },
            include: {
                // Podríamos incluir totales precalculados aquí o en otro método
            }
        });
    }

    async findAllAbiertas(empresaId: string, sucursalId: string) {
        return this.prisma.caja.findMany({
            where: {
                empresa_id: empresaId,
                sucursal_id: sucursalId,
                estado: 'ABIERTA'
            },
            include: { usuario: { select: { nombre: true, email: true } } }
        });
    }

    async abrir(empresaId: string, usuarioId: string, dto: OpenCajaDto) {
        const abierta = await this.findAbierta(empresaId, dto.sucursalId, usuarioId);
        if (abierta) throw new BadRequestException('Ya tienes una caja abierta en esta sucursal.');

        return this.prisma.caja.create({
            data: {
                empresa: { connect: { id: empresaId } },
                sucursal: { connect: { id: dto.sucursalId } },
                usuario: { connect: { id: usuarioId } },
                estado: 'ABIERTA',
                monto_apertura_centavos: BigInt(dto.montoApertura), // centavos
                apertura_at: new Date(),
            },
        });
    }

    async cerrar(id: string, dto: CloseCajaDto) {
        const caja = await this.prisma.caja.findUnique({ where: { id } });
        if (!caja || caja.estado !== 'ABIERTA') throw new BadRequestException('Caja no encontrada o ya cerrada');

        // Calcular sistema
        const pagos = await this.prisma.pago.aggregate({
            where: { caja_id: id, estado: 'APLICADO' },
            _sum: { monto_centavos: true },
        });

        // Total Sistema = Apertura + Pagos
        const totalSistema = (caja.monto_apertura_centavos || BigInt(0)) + (pagos._sum.monto_centavos || BigInt(0));
        const diferencia = BigInt(dto.montoCierre) - totalSistema;

        return this.prisma.caja.update({
            where: { id },
            data: {
                estado: 'CERRADA',
                cierre_at: new Date(),
                monto_cierre_centavos: BigInt(dto.montoCierre),
                diferencia_centavos: diferencia,
                nota_cierre: dto.notaCierre,
            },
        });
    }
}
