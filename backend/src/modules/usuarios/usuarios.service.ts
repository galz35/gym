import { Injectable, BadRequestException, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import { CreateUsuarioDto } from './dto/create-usuario.dto';
import { UpdateUsuarioDto } from './dto/update-usuario.dto';

@Injectable()
export class UsuariosService {
    constructor(private prisma: PrismaService) { }

    async findAll(empresaId: string) {
        return this.prisma.usuario.findMany({
            where: { empresa_id: empresaId },
            include: {
                roles: { include: { rol: true } },
                sucursales: { include: { sucursal: true } },
            },
        });
    }

    async findOne(id: string) {
        const user = await this.prisma.usuario.findUnique({
            where: { id },
            include: {
                roles: { include: { rol: true } },
                sucursales: { include: { sucursal: true } },
            },
        });
        if (!user) throw new NotFoundException('Usuario no encontrado');
        return user;
    }

    async create(createDto: CreateUsuarioDto) {
        const existing = await this.prisma.usuario.findFirst({
            where: { empresa_id: createDto.empresaId, email: createDto.email },
        });
        if (existing) throw new ConflictException('Email ya registrado en esta empresa');

        const hash = await bcrypt.hash(createDto.password, 10);

        return this.prisma.usuario.create({
            data: {
                empresa: { connect: { id: createDto.empresaId } },
                email: createDto.email,
                nombre: createDto.nombre,
                hash,
                estado: 'ACTIVO',
                token_version: 1,
                roles: createDto.roles?.length ? {
                    create: createDto.roles.map(rolId => ({ rol_id: rolId }))
                } : undefined,
                sucursales: createDto.sucursales?.length ? {
                    create: createDto.sucursales.map(sucId => ({ sucursal_id: sucId }))
                } : undefined
            },
            include: { roles: true, sucursales: true },
        });
    }

    async update(id: string, updateDto: UpdateUsuarioDto) {
        const data: any = { ...updateDto }; // Shallow copy
        if (updateDto.password) {
            data.hash = await bcrypt.hash(updateDto.password, 10);
            delete data.password;
        }

        return this.prisma.usuario.update({
            where: { id },
            data,
        });
    }

    async updateRoles(id: string, roleIds: number[]) {
        return this.prisma.$transaction(async (tx) => {
            await tx.usuarioRol.deleteMany({ where: { usuario_id: id } });
            await tx.usuarioRol.createMany({
                data: roleIds.map(rolId => ({ usuario_id: id, rol_id: rolId })),
            });
        });
    }

    async updateSucursales(id: string, sucursalIds: string[]) {
        return this.prisma.$transaction(async (tx) => {
            await tx.usuarioSucursal.deleteMany({ where: { usuario_id: id } });
            await tx.usuarioSucursal.createMany({
                data: sucursalIds.map(sucId => ({ usuario_id: id, sucursal_id: sucId })),
            });
        });
    }

    async setStatus(id: string, active: boolean) {
        const estado = active ? 'ACTIVO' : 'INACTIVO';
        const data: any = { estado };

        if (!active) {
            data.token_version = { increment: 1 };

            await this.prisma.refreshToken.updateMany({
                where: { usuario_id: id, revocado_at: null },
                data: { revocado_at: new Date() },
            });
        }

        return this.prisma.usuario.update({
            where: { id },
            data,
        });
    }
}
