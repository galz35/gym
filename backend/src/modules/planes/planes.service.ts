import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../common/database/database.service';
import { CreatePlanDto, UpdatePlanDto } from './dto/create-plan.dto';

@Injectable()
export class PlanesService {
    constructor(private db: DatabaseService) { }

    async findAll(empresaId: string, sucursalId?: string) {
        let planes;
        if (sucursalId) {
            planes = await this.db.sql`
                SELECT * FROM gym.plan_membresia 
                WHERE empresa_id = ${empresaId} 
                AND estado = 'ACTIVO' 
                AND (sucursal_id = ${sucursalId} OR sucursal_id IS NULL)
                ORDER BY precio_centavos ASC
            `;
        } else {
            planes = await this.db.sql`
                SELECT * FROM gym.plan_membresia 
                WHERE empresa_id = ${empresaId} 
                AND estado = 'ACTIVO'
                ORDER BY precio_centavos ASC
            `;
        }

        if (planes.length === 0) {
            await this.db.sql`
                INSERT INTO gym.plan_membresia (empresa_id, nombre, tipo, dias, precio_centavos, estado) VALUES 
                (${empresaId}, 'Pase de Día', 'DIAS', 1, 5000, 'ACTIVO'),
                (${empresaId}, 'Pase Semanal', 'SEMANAL', 7, 20000, 'ACTIVO'),
                (${empresaId}, 'Pase Mensual', 'MENSUAL', 30, 60000, 'ACTIVO')
            `;

            if (sucursalId) {
                planes = await this.db.sql`
                    SELECT * FROM gym.plan_membresia 
                    WHERE empresa_id = ${empresaId} 
                    AND estado = 'ACTIVO' 
                    AND (sucursal_id = ${sucursalId} OR sucursal_id IS NULL)
                    ORDER BY precio_centavos ASC
                `;
            } else {
                planes = await this.db.sql`
                    SELECT * FROM gym.plan_membresia 
                    WHERE empresa_id = ${empresaId} 
                    AND estado = 'ACTIVO'
                    ORDER BY precio_centavos ASC
                `;
            }
        }

        return planes;
    }

    async findOne(id: string) {
        const [plan] = await this.db.sql`SELECT * FROM gym.plan_membresia WHERE id = ${id}`;
        if (!plan) throw new NotFoundException('Plan no encontrado');
        return plan;
    }

    async create(empresaId: string, dto: CreatePlanDto) {
        if (dto.tipo === 'DIAS' && !dto.dias) throw new BadRequestException('Debe especificar días para tipo DIAS');
        if (dto.tipo === 'VISITAS' && !dto.visitas) throw new BadRequestException('Debe especificar visitas para tipo VISITAS');

        let dias = dto.dias;
        if (!dias) {
            if (dto.tipo === 'SEMANAL') dias = 7;
            if (dto.tipo === 'MENSUAL') dias = 30;
            if (dto.tipo === 'TRIMESTRAL') dias = 90;
            if (dto.tipo === 'SEMESTRAL') dias = 180;
            if (dto.tipo === 'ANUAL') dias = 365;
        }

        const precioCentavos = Math.round(dto.precio * 100);

        const [plan] = await this.db.sql`
            INSERT INTO gym.plan_membresia (
                empresa_id, sucursal_id, nombre, tipo, dias, visitas, precio_centavos, descripcion, multisede, estado
            ) VALUES (
                ${empresaId}, ${dto.sucursalId || null}, ${dto.nombre}, ${dto.tipo}, ${dias || null}, ${dto.visitas || null}, 
                ${precioCentavos}, ${dto.descripcion || null}, ${dto.multisede || false}, 'ACTIVO'
            ) RETURNING *
        `;
        return plan;
    }

    async update(id: string, dto: UpdatePlanDto) {
        const updates: any = { actualizado_at: this.db.sql`NOW()` };
        if (dto.nombre) updates.nombre = dto.nombre;
        if (dto.descripcion !== undefined) updates.descripcion = dto.descripcion;
        if (dto.precio !== undefined) updates.precio_centavos = Math.round(dto.precio * 100);
        if (dto.estado) updates.estado = dto.estado;

        const [plan] = await this.db.sql`
            UPDATE gym.plan_membresia SET ${this.db.sql(updates)}
            WHERE id = ${id}
            RETURNING *
        `;
        return plan;
    }
}
