import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../common/database/database.service';
import { SupabaseService } from '../../common/supabase/supabase.service';
import { CreateClienteDto, UpdateClienteDto, FindClienteDto } from './dto/create-cliente.dto';

interface MulterFile {
    buffer: Buffer;
    originalname: string;
    mimetype: string;
}

@Injectable()
export class ClientesService {
    constructor(
        private db: DatabaseService,
        private supabaseService: SupabaseService,
    ) { }

    async findAll(empresaId: string, query: FindClienteDto) {
        const { buscar, limit } = query;
        const take = limit ? Number(limit) : 50;

        if (buscar) {
            const searchParam = `%${buscar}%`;
            return this.db.sql`
                SELECT * FROM gym.cliente 
                WHERE empresa_id = ${empresaId}
                AND (
                    nombre ILIKE ${searchParam} OR 
                    telefono ILIKE ${searchParam} OR 
                    email ILIKE ${searchParam} OR 
                    documento ILIKE ${searchParam}
                )
                ORDER BY nombre ASC
                LIMIT ${take}
            `;
        }

        return this.db.sql`
            SELECT * FROM gym.cliente 
            WHERE empresa_id = ${empresaId}
            ORDER BY nombre ASC
            LIMIT ${take}
        `;
    }

    async findOne(id: string) {
        const [cliente] = await this.db.sql`
            SELECT * FROM gym.cliente WHERE id = ${id}
        `;
        if (!cliente) throw new NotFoundException('Cliente no encontrado');
        return cliente;
    }

    async create(empresaId: string, dto: CreateClienteDto) {
        const [cliente] = await this.db.sql`
            INSERT INTO gym.cliente (
                empresa_id, nombre, telefono, email, documento, estado
            ) VALUES (
                ${empresaId}, ${dto.nombre}, ${dto.telefono || null}, ${dto.email || null}, ${dto.documento || null}, 'ACTIVO'
            ) RETURNING *
        `;
        return cliente;
    }

    async update(id: string, dto: UpdateClienteDto) {
        const updates: any = { ...dto, actualizado_at: this.db.sql`NOW()` };

        const [cliente] = await this.db.sql`
            UPDATE gym.cliente SET ${this.db.sql(updates)}
            WHERE id = ${id}
            RETURNING *
        `;
        return cliente;
    }

    async uploadFoto(id: string, file: MulterFile) {
        const path = `clientes/${id}/${Date.now()}_${file.originalname}`;

        const url = await this.supabaseService.uploadFile('clientes', path, file.buffer, file.mimetype);

        if (url) {
            await this.db.sql`
                UPDATE gym.cliente 
                SET foto_url = ${url}, actualizado_at = NOW()
                WHERE id = ${id}
            `;
        }
        return { url };
    }
}
