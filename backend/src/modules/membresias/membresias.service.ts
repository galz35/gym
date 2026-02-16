import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class MembresiasService {
    constructor(private prisma: PrismaService) { }

    async findAll(empresaId: string, sucursalId?: string) {
        return this.prisma.membresiaCliente.findMany({
            where: {
                empresa_id: empresaId,
                ...(sucursalId ? { sucursal_id: sucursalId } : {}),
            },
            include: {
                cliente: { select: { nombre: true, email: true, telefono: true } },
                plan: { select: { nombre: true, tipo: true, dias: true, visitas: true } },
            },
            orderBy: { creado_at: 'desc' },
        });
    }

    async create(empresaId: string, dto: any) {
        const plan = await this.prisma.planMembresia.findUnique({
            where: { id: dto.plan_id },
        });

        if (!plan) throw new NotFoundException('Plan no encontrado');

        const inicio = dto.inicio ? new Date(dto.inicio) : new Date();
        const fin = new Date(inicio);

        if (plan.tipo === 'DIAS' && plan.dias) {
            fin.setDate(fin.getDate() + plan.dias);
        } else if (plan.tipo === 'VISITAS') {
            // Un mes por defecto para planes de visitas si no se especifica
            fin.setMonth(fin.getMonth() + 1);
        }

        return this.prisma.membresiaCliente.create({
            data: {
                empresa: { connect: { id: empresaId } },
                sucursal: { connect: { id: dto.sucursal_id } },
                cliente: { connect: { id: dto.cliente_id } },
                plan: { connect: { id: dto.plan_id } },
                inicio,
                fin,
                visitas_restantes: plan.visitas,
                estado: 'ACTIVA',
                monto_centavos: plan.precio_centavos,
            },
            include: {
                cliente: { select: { nombre: true } },
                plan: { select: { nombre: true } },
            }
        });
    }

    async renovar(id: string, dto: any) {
        const anterior = await this.prisma.membresiaCliente.findUnique({
            where: { id },
            include: { plan: true },
        });

        if (!anterior) throw new NotFoundException('Membresía no encontrada');

        // Desactivar anterior
        await this.prisma.membresiaCliente.update({
            where: { id },
            data: { estado: 'RENOVADA' },
        });

        // Crear nueva (usando la fecha de fin anterior si es futura, o hoy si ya venció)
        const hoy = new Date();
        const inicio = anterior.fin > hoy ? new Date(anterior.fin) : hoy;

        return this.create(anterior.empresa_id, {
            ...dto,
            cliente_id: anterior.cliente_id,
            plan_id: dto.plan_id || anterior.plan_id,
            sucursal_id: anterior.sucursal_id,
            inicio: inicio,
        });
    }

    async setStatus(id: string, estado: string) {
        return this.prisma.membresiaCliente.update({
            where: { id },
            data: { estado },
        });
    }
}
