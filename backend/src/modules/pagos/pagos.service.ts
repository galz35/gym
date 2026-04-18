import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../common/database/database.service';
import { CreateGastoDto } from './dto/create-gasto.dto';

@Injectable()
export class PagosService {
  constructor(private db: DatabaseService) {}

  async findByCaja(empresaId: string, cajaId: string) {
    if (!cajaId) {
      throw new BadRequestException('cajaId es requerido');
    }

    return this.db.sql`
            SELECT *
            FROM gym.pago
            WHERE empresa_id = ${empresaId}
              AND caja_id = ${cajaId}
              AND estado = 'APLICADO'
            ORDER BY creado_at DESC
        `;
  }

  async createGasto(
    empresaId: string,
    usuarioId: string,
    dto: CreateGastoDto,
  ) {
    const [caja] = await this.db.sql`
            SELECT *
            FROM gym.caja
            WHERE id = ${dto.caja_id}
              AND empresa_id = ${empresaId}
        `;

    if (!caja) {
      throw new NotFoundException('Caja no encontrada');
    }

    if (caja.estado !== 'ABIERTA') {
      throw new BadRequestException('La caja no está abierta');
    }

    const [pago] = await this.db.sql`
            INSERT INTO gym.pago (
                empresa_id,
                sucursal_id,
                caja_id,
                cliente_id,
                tipo,
                referencia_id,
                monto_centavos,
                metodo,
                referencia,
                estado
            ) VALUES (
                ${empresaId},
                ${caja.sucursal_id},
                ${dto.caja_id},
                NULL,
                'GASTO',
                NULL,
                ${dto.monto_centavos},
                'EFECTIVO',
                ${dto.descripcion || null},
                'APLICADO'
            )
            RETURNING *
        `;

    return pago;
  }
}
