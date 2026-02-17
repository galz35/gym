import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreatePlanDto, UpdatePlanDto } from './dto/create-plan.dto';

@Injectable()
export class PlanesService {
    constructor(private prisma: PrismaService) { }

    async findAll(empresaId: string, sucursalId?: string) {
        let where: any = { empresa_id: empresaId, estado: 'ACTIVO' };

        if (sucursalId) {
            where = {
                ...where,
                OR: [
                    { sucursal_id: sucursalId },
                    { sucursal_id: null } // Global
                ]
            };
        }

        return this.prisma.planMembresia.findMany({
            where,
            orderBy: { precio_centavos: 'asc' },
        });
    }

    async findOne(id: string) {
        const plan = await this.prisma.planMembresia.findUnique({
            where: { id },
        });
        if (!plan) throw new NotFoundException('Plan no encontrado');
        return plan;
    }

    async create(empresaId: string, dto: CreatePlanDto) {
        // Validar lógica de negocio simple
        if (dto.tipo === 'DIAS' && !dto.dias) throw new BadRequestException('Debe especificar días para tipo DIAS');
        if (dto.tipo === 'VISITAS' && !dto.visitas) throw new BadRequestException('Debe especificar visitas para tipo VISITAS');

        // Auto-fill dias for common types if not specified
        let dias = dto.dias;
        if (!dias) {
            if (dto.tipo === 'SEMANAL') dias = 7;
            if (dto.tipo === 'MENSUAL') dias = 30;
            if (dto.tipo === 'TRIMESTRAL') dias = 90;
            if (dto.tipo === 'SEMESTRAL') dias = 180;
            if (dto.tipo === 'ANUAL') dias = 365;
        }

        return this.prisma.planMembresia.create({
            data: {
                empresa: { connect: { id: empresaId } },
                sucursal: dto.sucursalId ? { connect: { id: dto.sucursalId } } : undefined, // Opcional
                nombre: dto.nombre,
                tipo: dto.tipo,
                dias: dias,
                visitas: dto.visitas,
                precio_centavos: BigInt(Math.round(dto.precio * 100)),
                descripcion: dto.descripcion,
                multisede: dto.multisede || false,
                estado: 'ACTIVO',
            },
        });
    }

    async update(id: string, dto: UpdatePlanDto) {
        const data: any = { actualizado_at: new Date() };
        if (dto.nombre) data.nombre = dto.nombre;
        if (dto.descripcion !== undefined) data.descripcion = dto.descripcion;
        if (dto.precio !== undefined) data.precio_centavos = BigInt(Math.round(dto.precio * 100));
        if (dto.estado) data.estado = dto.estado;

        return this.prisma.planMembresia.update({
            where: { id },
            data,
        });
    }
}
