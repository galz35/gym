import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../common/database/database.service';

@Injectable()
export class MembresiasService {
    constructor(private db: DatabaseService) { }

    async findAll(empresaId: string, sucursalId?: string) {
        if (sucursalId) {
            return this.db.sql`
                SELECT 
                    m.*,
                    json_build_object('nombre', c.nombre, 'email', c.email, 'telefono', c.telefono) as cliente,
                    json_build_object('nombre', p.nombre, 'tipo', p.tipo, 'dias', p.dias, 'visitas', p.visitas) as plan
                FROM gym.membresia_cliente m
                JOIN gym.cliente c ON m.cliente_id = c.id
                JOIN gym.plan_membresia p ON m.plan_id = p.id
                WHERE m.empresa_id = ${empresaId} AND m.sucursal_id = ${sucursalId}
                ORDER BY m.creado_at DESC
            `;
        } else {
            return this.db.sql`
                SELECT 
                    m.*,
                    json_build_object('nombre', c.nombre, 'email', c.email, 'telefono', c.telefono) as cliente,
                    json_build_object('nombre', p.nombre, 'tipo', p.tipo, 'dias', p.dias, 'visitas', p.visitas) as plan
                FROM gym.membresia_cliente m
                JOIN gym.cliente c ON m.cliente_id = c.id
                JOIN gym.plan_membresia p ON m.plan_id = p.id
                WHERE m.empresa_id = ${empresaId}
                ORDER BY m.creado_at DESC
            `;
        }
    }

    async create(empresaId: string, dto: any) {
        const [plan] = await this.db.sql`SELECT * FROM gym.plan_membresia WHERE id = ${dto.plan_id}`;

        if (!plan) throw new NotFoundException('Plan no encontrado');

        const inicio = dto.inicio ? new Date(dto.inicio) : new Date();
        const fin = new Date(inicio);

        if (plan.dias && plan.dias > 0) {
            fin.setDate(fin.getDate() + plan.dias);
        } else if (plan.tipo === 'VISITAS') {
            fin.setMonth(fin.getMonth() + 1);
        } else {
            fin.setMonth(fin.getMonth() + 1);
        }

        const [membresia] = await this.db.sql`
            INSERT INTO gym.membresia_cliente (
                empresa_id, sucursal_id, cliente_id, plan_id, inicio, fin, visitas_restantes, estado
            ) VALUES (
                ${empresaId}, ${dto.sucursal_id}, ${dto.cliente_id}, ${dto.plan_id}, ${inicio}, ${fin}, ${plan.visitas}, 'ACTIVA'
            ) RETURNING *
        `;

        const [cliente] = await this.db.sql`SELECT nombre FROM gym.cliente WHERE id = ${dto.cliente_id}`;

        return {
            ...membresia,
            cliente: { nombre: cliente?.nombre },
            plan: { nombre: plan.nombre }
        };
    }

    async renovar(id: string, dto: any) {
        const [anterior] = await this.db.sql`
            SELECT m.*, row_to_json(p) as plan
            FROM gym.membresia_cliente m
            JOIN gym.plan_membresia p ON m.plan_id = p.id
            WHERE m.id = ${id}
        `;

        if (!anterior) throw new NotFoundException('Membresía no encontrada');

        // Desactivar anterior
        await this.db.sql`
            UPDATE gym.membresia_cliente SET estado = 'RENOVADA' WHERE id = ${id}
        `;

        // Crear nueva
        const hoy = new Date();
        const anteriorFin = new Date(anterior.fin);
        const inicio = anteriorFin > hoy ? anteriorFin : hoy;

        return this.create(anterior.empresa_id, {
            ...dto,
            cliente_id: anterior.cliente_id,
            plan_id: dto.plan_id || anterior.plan_id,
            sucursal_id: anterior.sucursal_id,
            inicio: inicio,
        });
    }

    async setStatus(id: string, estado: string) {
        const [membresia] = await this.db.sql`
            UPDATE gym.membresia_cliente SET estado = ${estado} WHERE id = ${id} RETURNING *
        `;
        return membresia;
    }
}
