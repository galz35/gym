import {
  Injectable,
  BadRequestException,
  PreconditionFailedException,
} from '@nestjs/common';
import { DatabaseService } from '../../common/database/database.service';
import { OpenCajaDto, CloseCajaDto } from './dto/actions-caja.dto';

@Injectable()
export class CajaService {
  constructor(private db: DatabaseService) {}

  async findAbierta(empresaId: string, sucursalId: string, usuarioId: string) {
    const [caja] = await this.db.sql`
            SELECT c.*
            FROM gym.caja c
            WHERE c.empresa_id = ${empresaId}
              AND c.sucursal_id = ${sucursalId}
              AND c.usuario_id = ${usuarioId}
              AND c.estado = 'ABIERTA'
            LIMIT 1
        `;
    return caja;
  }

  async findAllAbiertas(empresaId: string, sucursalId: string) {
    return this.db.sql`
            SELECT c.*, row_to_json(u) as usuario
            FROM gym.caja c
            JOIN gym.usuario u ON c.usuario_id = u.id
            WHERE c.empresa_id = ${empresaId}
              AND c.sucursal_id = ${sucursalId}
              AND c.estado = 'ABIERTA'
        `;
  }

  async abrir(empresaId: string, usuarioId: string, dto: OpenCajaDto) {
    const abierta = await this.findAbierta(
      empresaId,
      dto.sucursalId,
      usuarioId,
    );
    if (abierta)
      throw new BadRequestException(
        'Ya tienes una caja abierta en esta sucursal.',
      );

    const [caja] = await this.db.sql`
            INSERT INTO gym.caja (empresa_id, sucursal_id, usuario_id, estado, monto_apertura_centavos, apertura_at)
            VALUES (${empresaId}, ${dto.sucursalId}, ${usuarioId}, 'ABIERTA', ${dto.montoApertura}, NOW())
            RETURNING *
        `;
    return caja;
  }

  async cerrar(id: string, dto: CloseCajaDto) {
    const [caja] = await this.db.sql`SELECT * FROM gym.caja WHERE id = ${id}`;
    if (!caja || caja.estado !== 'ABIERTA')
      throw new BadRequestException('Caja no encontrada o ya cerrada');

    // Calcular sistema
    const [pagosAgg] = await this.db.sql`
            SELECT sum(monto_centavos)::bigint as total
            FROM gym.pago
            WHERE caja_id = ${id} AND estado = 'APLICADO'
        `;

    const montoPagos =
      pagosAgg && pagosAgg.total ? BigInt(pagosAgg.total) : BigInt(0);
    const montoApertura = caja.monto_apertura_centavos
      ? BigInt(caja.monto_apertura_centavos)
      : BigInt(0);
    const montoCierre = BigInt(dto.montoCierre);

    // Total Sistema = Apertura + Pagos
    const totalSistema = montoApertura + montoPagos;
    const diferencia = montoCierre - totalSistema;

    const [cajaActualizada] = await this.db.sql`
            UPDATE gym.caja
            SET estado = 'CERRADA',
                cierre_at = NOW(),
                monto_cierre_centavos = ${montoCierre.toString()},
                diferencia_centavos = ${diferencia.toString()},
                nota_cierre = ${dto.notaCierre || null}
            WHERE id = ${id}
            RETURNING *
        `;
    return cajaActualizada;
  }
}
