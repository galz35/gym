import {
  Injectable,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { DatabaseService } from '../../common/database/database.service';
import { ValidarAccesoDto } from './dto/validar-acceso.dto';

@Injectable()
export class AsistenciaService {
  constructor(private db: DatabaseService) {}

  async validarAcceso(
    empresaId: string,
    usuarioId: string,
    dto: ValidarAccesoDto,
  ) {
    const [result] = await this.db.sql`
            SELECT gym.fn_checkin_express(
                ${empresaId}, 
                ${dto.sucursalId}, 
                ${dto.clienteId}, 
                ${usuarioId}, 
                ${dto.notas || null}
            ) as res
        `;

    if (result.res.error) {
      throw new ForbiddenException(result.res.error);
    }

    return result.res;
  }

  async registrarSalida(clienteId: string, sucursalId: string) {
    const [updated] = await this.db.sql`
            WITH ultima AS (
                SELECT id 
                FROM gym.asistencia 
                WHERE cliente_id = ${clienteId} 
                  AND sucursal_id = ${sucursalId} 
                  AND fecha_salida IS NULL 
                  AND resultado = 'PERMITIDO'
                ORDER BY fecha_hora DESC
                LIMIT 1
            )
            UPDATE gym.asistencia 
            SET fecha_salida = NOW() 
            WHERE id = (SELECT id FROM ultima)
            RETURNING id
        `;

    if (!updated) {
      throw new BadRequestException(
        'No se encontró una entrada activa para este cliente.',
      );
    }

    return {
      acceso: true,
      motivo: 'OK',
      mensaje: 'Salida registrada correctamente',
      cliente: { id: clienteId },
      asistenciaId: updated.id,
    };
  }

  async findRecientes(
    empresaId: string,
    sucursalId: string,
    limit: number = 10,
  ) {
    return await this.db.sql`
            SELECT 
                a.*, 
                json_build_object(
                    'id', c.id, 
                    'nombre', c.nombre, 
                    'foto_url', c.foto_url,
                    'telefono', c.telefono
                ) as cliente
            FROM gym.asistencia a
            JOIN gym.cliente c ON a.cliente_id = c.id
            WHERE a.empresa_id = ${empresaId} AND a.sucursal_id = ${sucursalId}
            ORDER BY a.fecha_hora DESC
            LIMIT ${Number(limit) || 10}
        `;
  }
}
