import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { DatabaseService } from '../../common/database/database.service';

@Injectable()
export class MembresiasService {
  constructor(private db: DatabaseService) {}

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
    return await this.db.sql.begin(async (sql: any) => {
      const [plan] =
        await sql`SELECT * FROM gym.plan_membresia WHERE id = ${dto.plan_id}`;

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

      const [membresia] = await sql`
                INSERT INTO gym.membresia_cliente (
                    empresa_id, sucursal_id, cliente_id, plan_id, inicio, fin, visitas_restantes, estado
                ) VALUES (
                    ${empresaId}, ${dto.sucursal_id}, ${dto.cliente_id}, ${dto.plan_id}, ${inicio}, ${fin}, ${plan.visitas}, 'ACTIVA'
                ) RETURNING *
            `;

      // Opcional: Registrar venta y movimiento en caja
      if (dto.caja_id) {
        const metodo = dto.metodo_pago || 'EFECTIVO';
        const [venta] = await sql`
                    INSERT INTO gym.venta (empresa_id, sucursal_id, caja_id, total, metodo_pago, estado)
                    VALUES (${empresaId}, ${dto.sucursal_id}, ${dto.caja_id}, ${plan.precio}, ${metodo}, 'COMPLETADA')
                    RETURNING *
                `;

        await sql`
                    INSERT INTO gym.venta_detalle (venta_id, plan_id, cantidad, precio_unitario, subtotal)
                    VALUES (${venta.id}, ${plan.id}, 1, ${plan.precio}, ${plan.precio})
                `;

        await sql`
                    INSERT INTO gym.movimiento_caja (caja_id, tipo, monto, metodo_pago, concepto, venta_id)
                    VALUES (${dto.caja_id}, 'INGRESO', ${plan.precio}, ${metodo}, 'Venta de Plan: ' || ${plan.nombre}, ${venta.id})
                `;
      }

      const [cliente] =
        await sql`SELECT nombre FROM gym.cliente WHERE id = ${dto.cliente_id}`;

      return {
        ...membresia,
        cliente: { nombre: cliente?.nombre },
        plan: { nombre: plan.nombre },
      };
    });
  }

  async renovar(id: string, dto: any) {
    return await this.db.sql.begin(async (sql: any) => {
      const [anterior] = await sql`
                SELECT m.*, row_to_json(p) as plan
                FROM gym.membresia_cliente m
                JOIN gym.plan_membresia p ON m.plan_id = p.id
                WHERE m.id = ${id}
            `;

      if (!anterior) throw new NotFoundException('Membresía no encontrada');

      // Desactivar anterior
      await sql`
                UPDATE gym.membresia_cliente SET estado = 'RENOVADA' WHERE id = ${id}
            `;

      // Crear nueva
      const hoy = new Date();
      const anteriorFin = new Date(anterior.fin);
      const inicio = anteriorFin > hoy ? anteriorFin : hoy;

      // Para que create use la misma transacción, tendríamos que pasarle el objeto 'sql'
      // O simplemente mover la lógica aquí. Vamos a mover la lógica para ser más limpios.
      const [plan] =
        await sql`SELECT * FROM gym.plan_membresia WHERE id = ${dto.plan_id || anterior.plan_id}`;
      if (!plan) throw new NotFoundException('Plan no encontrado');

      const nuevaFin = new Date(inicio);
      if (plan.dias && plan.dias > 0) {
        nuevaFin.setDate(nuevaFin.getDate() + plan.dias);
      } else {
        nuevaFin.setMonth(nuevaFin.getMonth() + 1);
      }

      const [membresia] = await sql`
                INSERT INTO gym.membresia_cliente (
                    empresa_id, sucursal_id, cliente_id, plan_id, inicio, fin, visitas_restantes, estado
                ) VALUES (
                    ${anterior.empresa_id}, ${anterior.sucursal_id}, ${anterior.cliente_id}, ${plan.id}, ${inicio}, ${nuevaFin}, ${plan.visitas}, 'ACTIVA'
                ) RETURNING *
            `;

      const [cliente] =
        await sql`SELECT nombre FROM gym.cliente WHERE id = ${anterior.cliente_id}`;

      // Opcional: Registrar venta y movimiento en caja
      if (dto.caja_id) {
        const metodo = dto.metodo_pago || 'EFECTIVO';
        const [venta] = await sql`
                    INSERT INTO gym.venta (empresa_id, sucursal_id, caja_id, total, metodo_pago, estado)
                    VALUES (${anterior.empresa_id}, ${anterior.sucursal_id}, ${dto.caja_id}, ${plan.precio}, ${metodo}, 'COMPLETADA')
                    RETURNING *
                `;

        await sql`
                    INSERT INTO gym.venta_detalle (venta_id, plan_id, cantidad, precio_unitario, subtotal)
                    VALUES (${venta.id}, ${plan.id}, 1, ${plan.precio}, ${plan.precio})
                `;

        await sql`
                    INSERT INTO gym.movimiento_caja (caja_id, tipo, monto, metodo_pago, concepto, venta_id)
                    VALUES (${dto.caja_id}, 'INGRESO', ${plan.precio}, ${metodo}, 'Renovación de Plan: ' || ${plan.nombre}, ${venta.id})
                `;
      }

      return {
        ...membresia,
        cliente: { nombre: cliente?.nombre },
        plan: { nombre: plan.nombre },
      };
    });
  }

  async setStatus(id: string, estado: string) {
    const [membresia] = await this.db.sql`
            UPDATE gym.membresia_cliente SET estado = ${estado} WHERE id = ${id} RETURNING *
        `;
    return membresia;
  }
}
