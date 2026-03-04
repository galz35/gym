import {
  Injectable,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { DatabaseService } from '../../common/database/database.service';

@Injectable()
export class VentasService {
  constructor(private db: DatabaseService) {}

  async createVenta(
    empresaId: string,
    sucursalId: string,
    usuarioId: string,
    payload: any,
  ) {
    const { cajaId, clienteId, totalCentavos, detalles, pagos } = payload;

    if (totalCentavos < 0) {
      throw new BadRequestException('El monto total no puede ser negativo');
    }

    return await this.db.sql.begin(async (sql: any) => {
      if (cajaId) {
        const [caja] =
          await sql`SELECT estado FROM gym.caja WHERE id = ${cajaId}`;
        if (!caja || caja.estado !== 'ABIERTA') {
          throw new BadRequestException(
            'La caja proporcionada no está abierta o no existe',
          );
        }
      }

      const [venta] = await sql`
                INSERT INTO gym.venta (empresa_id, sucursal_id, cliente_id, caja_id, total_centavos, estado)
                VALUES (${empresaId}, ${sucursalId}, ${clienteId || null}, ${cajaId || null}, ${totalCentavos}, 'APLICADA')
                RETURNING *
            `;

      for (const det of detalles) {
        const [updateResult] = await sql`
                    UPDATE gym.inventario_sucursal 
                    SET existencia = existencia - ${det.cantidad}, actualizado_at = NOW()
                    WHERE sucursal_id = ${sucursalId} 
                    AND producto_id = ${det.productoId} 
                    AND existencia >= ${det.cantidad}
                    RETURNING *
                `;

        if (!updateResult) {
          throw new ConflictException(
            `Stock insuficiente para producto ${det.productoId}`,
          );
        }

        await sql`
                    INSERT INTO gym.detalle_venta (venta_id, producto_id, cantidad, precio_unit_centavos, subtotal_centavos)
                    VALUES (${venta.id}, ${det.productoId}, ${det.cantidad}, ${det.precioUnit}, ${det.subtotal})
                `;

        await sql`
                    INSERT INTO gym.movimiento_inventario (empresa_id, sucursal_id, producto_id, usuario_id, tipo, cantidad, ref_tipo, ref_id)
                    VALUES (${empresaId}, ${sucursalId}, ${det.productoId}, ${usuarioId}, 'SALIDA', ${det.cantidad}, 'VENTA', ${venta.id})
                `;
      }

      if (pagos && pagos.length > 0) {
        for (const p of pagos) {
          await sql`
                        INSERT INTO gym.pago (empresa_id, sucursal_id, caja_id, cliente_id, tipo, referencia_id, monto_centavos, metodo, referencia, estado)
                        VALUES (${empresaId}, ${sucursalId}, ${cajaId || null}, ${clienteId || null}, 'PRODUCTO', ${venta.id}, ${p.monto}, ${p.metodo || 'EFECTIVO'}, ${p.referencia || null}, 'APLICADO')
                    `;
        }
      }

      return venta;
    });
  }
}
