import { Injectable, BadRequestException, ConflictException } from '@nestjs/common';
import { DatabaseService } from '../../common/database/database.service';
import { CreateTrasladoDto } from './dto/traslado.dto';

@Injectable()
export class TrasladosService {
    constructor(private db: DatabaseService) { }

    async crear(empresaId: string, usuarioId: string, dto: CreateTrasladoDto) {
        if (dto.sucursalOrigenId === dto.sucursalDestinoId) {
            throw new BadRequestException('Origen y destino deben ser diferentes');
        }

        return await this.db.sql.begin(async (sql: any) => {
            const [traslado] = await sql`
                INSERT INTO gym.traslado_inventario (empresa_id, sucursal_origen_id, sucursal_destino_id, creado_por, estado)
                VALUES (${empresaId}, ${dto.sucursalOrigenId}, ${dto.sucursalDestinoId}, ${usuarioId}, 'CREADO')
                RETURNING *
            `;

            for (const det of dto.detalles) {
                await sql`
                    INSERT INTO gym.traslado_detalle (traslado_id, producto_id, cantidad)
                    VALUES (${traslado.id}, ${det.productoId}, ${det.cantidad})
                `;

                const [updated] = await sql`
                    UPDATE gym.inventario_sucursal
                    SET existencia = existencia - ${det.cantidad}, actualizado_at = NOW()
                    WHERE sucursal_id = ${dto.sucursalOrigenId} AND producto_id = ${det.productoId} AND existencia >= ${det.cantidad}
                    RETURNING *
                `;

                if (!updated) {
                    throw new ConflictException(`Stock insuficiente en origen para producto ${det.productoId}`);
                }

                await sql`
                    INSERT INTO gym.movimiento_inventario (empresa_id, sucursal_id, producto_id, usuario_id, tipo, cantidad, ref_tipo, ref_id)
                    VALUES (${empresaId}, ${dto.sucursalOrigenId}, ${det.productoId}, ${usuarioId}, 'TRASLADO_SALIDA', ${det.cantidad}, 'TRASLADO', ${traslado.id})
                `;
            }

            return traslado;
        });
    }

    async recibir(trasladoId: string, usuarioId: string) {
        return await this.db.sql.begin(async (sql: any) => {
            const [updated] = await sql`
                UPDATE gym.traslado_inventario
                SET estado = 'RECIBIDO', recibido_por = ${usuarioId}, recibido_at = NOW()
                WHERE id = ${trasladoId} AND estado = 'CREADO'
                RETURNING *
            `;

            if (!updated) {
                throw new BadRequestException('Traslado no válido para recepción o ya fue recibido previamente');
            }

            const detalles = await sql`SELECT * FROM gym.traslado_detalle WHERE traslado_id = ${trasladoId}`;

            for (const det of detalles) {
                await sql`
                    INSERT INTO gym.inventario_sucursal (empresa_id, sucursal_id, producto_id, existencia)
                    VALUES (${updated.empresa_id}, ${updated.sucursal_destino_id}, ${det.producto_id}, ${det.cantidad})
                    ON CONFLICT (sucursal_id, producto_id)
                    DO UPDATE SET existencia = gym.inventario_sucursal.existencia + EXCLUDED.existencia, actualizado_at = NOW()
                `;

                await sql`
                    INSERT INTO gym.movimiento_inventario (empresa_id, sucursal_id, producto_id, usuario_id, tipo, cantidad, ref_tipo, ref_id)
                    VALUES (${updated.empresa_id}, ${updated.sucursal_destino_id}, ${det.producto_id}, ${usuarioId}, 'TRASLADO_ENTRADA', ${det.cantidad}, 'TRASLADO', ${updated.id})
                `;
            }

            return updated;
        });
    }

    async findAllPendientes(empresaId: string, sucursalDestinoId: string) {
        return this.db.sql`
            SELECT t.*, 
                   json_build_object('nombre', so.nombre) as sucursal_origen,
                   json_build_object('nombre', u.nombre) as usuario_crea,
                   (SELECT json_agg(json_build_object(
                       'producto_id', d.producto_id,
                       'cantidad', d.cantidad,
                       'producto', json_build_object('nombre', p.nombre)
                   )) 
                    FROM gym.traslado_detalle d
                    JOIN gym.producto p ON d.producto_id = p.id
                    WHERE d.traslado_id = t.id) as detalles
            FROM gym.traslado_inventario t
            JOIN gym.sucursal so ON t.sucursal_origen_id = so.id
            JOIN gym.usuario u ON t.creado_por = u.id
            WHERE t.empresa_id = ${empresaId}
              AND t.sucursal_destino_id = ${sucursalDestinoId}
              AND t.estado = 'CREADO'
            ORDER BY t.creado_at DESC
        `;
    }
}
