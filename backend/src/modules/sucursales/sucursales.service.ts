import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateSucursalDto, UpdateSucursalDto } from './dto/create-sucursal.dto';

@Injectable()
export class SucursalesService {
    constructor(private prisma: PrismaService) { }

    async findAll(empresaId: string) {
        return this.prisma.sucursal.findMany({
            where: { empresa_id: empresaId },
        });
    }

    async findOne(id: string) {
        const sucursal = await this.prisma.sucursal.findUnique({
            where: { id },
        });
        if (!sucursal) throw new NotFoundException('Sucursal no encontrada');
        return sucursal;
    }

    async create(dto: CreateSucursalDto) {
        return this.prisma.sucursal.create({
            data: {
                empresa: { connect: { id: dto.empresaId } },
                nombre: dto.nombre,
                direccion: dto.direccion,
                config_json: dto.configJson || {},
            },
        });
    }

    async update(id: string, dto: UpdateSucursalDto) {
        return this.prisma.sucursal.update({
            where: { id },
            data: {
                ...dto,
                actualizado_at: new Date(),
            },
        });
    }

    async setStatus(id: string, active: boolean) {
        return this.prisma.sucursal.update({
            where: { id },
            data: {
                estado: active ? 'ACTIVO' : 'INACTIVO',
                actualizado_at: new Date(),
            },
        });
    }
}
