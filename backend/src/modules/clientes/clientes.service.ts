import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { SupabaseService } from '../../common/supabase/supabase.service';
import { CreateClienteDto, UpdateClienteDto, FindClienteDto } from './dto/create-cliente.dto';

@Injectable()
export class ClientesService {
    constructor(
        private prisma: PrismaService,
        private supabaseService: SupabaseService,
    ) { }

    async findAll(empresaId: string, query: FindClienteDto) {
        const { buscar, limit } = query;
        const take = limit ? Number(limit) : 50;

        let where: any = { empresa_id: empresaId };

        // Búsqueda (trgm o ilike)
        if (buscar) {
            where = {
                ...where,
                OR: [
                    { nombre: { contains: buscar, mode: 'insensitive' } },
                    { telefono: { contains: buscar } },
                    { email: { contains: buscar, mode: 'insensitive' } },
                    { documento: { contains: buscar } },
                ],
            };
        }

        return this.prisma.cliente.findMany({
            where,
            orderBy: { nombre: 'asc' },
            take,
        });
    }

    async findOne(id: string) {
        const cliente = await this.prisma.cliente.findUnique({
            where: { id },
        });
        if (!cliente) throw new NotFoundException('Cliente no encontrado');
        return cliente;
    }

    async create(empresaId: string, dto: CreateClienteDto) {
        return this.prisma.cliente.create({
            data: {
                empresa: { connect: { id: empresaId } },
                nombre: dto.nombre,
                telefono: dto.telefono,
                email: dto.email,
                documento: dto.documento,
                estado: 'ACTIVO',
            },
        });
    }

    async update(id: string, dto: UpdateClienteDto) {
        return this.prisma.cliente.update({
            where: { id },
            data: {
                ...dto,
                actualizado_at: new Date(),
            },
        });
    }

    async uploadFoto(id: string, file: Express.Multer.File) {
        const path = `clientes/${id}/${Date.now()}_${file.originalname}`;
        // En caso de que SupabaseService no esté configurado (dev mode sin credenciales), 
        // esto devolverá null o error, el frontend debe manejarlo.
        // Si hay una URL hardcoded para dev, este es el lugar para mockearlo si se quisiera, 
        // pero "nada quemado" implica usar el servicio real.

        const url = await this.supabaseService.uploadFile('clientes', path, file.buffer, file.mimetype);

        if (url) {
            await this.prisma.cliente.update({
                where: { id },
                data: { foto_url: url, actualizado_at: new Date() }
            });
        }
        return { url };
    }
}
