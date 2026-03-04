import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../common/database/database.service';

@Injectable()
export class ReportesService {
  constructor(private db: DatabaseService) {}

  async getResumenDia(empresaId: string, sucursalId: string, fecha: Date) {
    // Definir rango del día
    const inicio = new Date(fecha.setHours(0, 0, 0, 0));
    const fin = new Date(fecha.setHours(23, 59, 59, 999));

    // Consultas paralelas para dashboard
    const [[asistencias], [salidas], [ventas], [pagos], [nuevosClientes]] =
      await Promise.all([
        this.db
          .sql`SELECT count(*)::integer FROM gym.asistencia WHERE empresa_id = ${empresaId} AND sucursal_id = ${sucursalId} AND fecha_hora >= ${inicio} AND fecha_hora <= ${fin}`,
        this.db
          .sql`SELECT count(*)::integer FROM gym.asistencia WHERE empresa_id = ${empresaId} AND sucursal_id = ${sucursalId} AND fecha_salida >= ${inicio} AND fecha_salida <= ${fin}`,
        this.db
          .sql`SELECT count(*)::integer as cant, sum(total_centavos)::bigint as total FROM gym.venta WHERE empresa_id = ${empresaId} AND sucursal_id = ${sucursalId} AND creado_at >= ${inicio} AND creado_at <= ${fin} AND estado = 'APLICADA'`,
        this.db
          .sql`SELECT sum(monto_centavos)::bigint as total FROM gym.pago WHERE empresa_id = ${empresaId} AND sucursal_id = ${sucursalId} AND creado_at >= ${inicio} AND creado_at <= ${fin} AND estado = 'APLICADO'`,
        this.db
          .sql`SELECT count(*)::integer FROM gym.cliente WHERE empresa_id = ${empresaId} AND creado_at >= ${inicio} AND creado_at <= ${fin}`,
      ]);

    return {
      fecha: inicio.toISOString(),
      asistencias: asistencias?.count || 0,
      salidas: salidas?.count || 0,
      ventas: {
        cantidad: ventas?.cant || 0,
        total: Number(ventas?.total || 0) / 100,
      },
      ingresos: Number(pagos?.total || 0) / 100,
      nuevosClientes: nuevosClientes?.count || 0,
    };
  }

  async getVencimientos(
    empresaId: string,
    sucursalId: string,
    diasProximos: number,
  ) {
    const hoy = new Date();
    const limite = new Date();
    limite.setDate(hoy.getDate() + diasProximos);

    const results = await this.db.sql`
            SELECT 
                m.*,
                json_build_object('nombre', c.nombre, 'foto_url', c.foto_url) as cliente,
                json_build_object('nombre', p.nombre) as plan
            FROM gym.membresia_cliente m
            JOIN gym.cliente c ON m.cliente_id = c.id
            JOIN gym.plan_membresia p ON m.plan_id = p.id
            WHERE m.empresa_id = ${empresaId}
              AND m.sucursal_id = ${sucursalId}
              AND m.fin >= ${hoy}
              AND m.fin <= ${limite}
              AND m.estado = 'ACTIVA'
            ORDER BY m.fin ASC
        `;
    return results;
  }

  async getVentasRango(
    empresaId: string,
    sucursalId: string,
    desde: Date,
    hasta: Date,
  ) {
    // En raw format devolver la estructura es un poco manual, pero se arma rápido
    const ventas = await this.db.sql`
            SELECT 
                v.*,
                json_build_object('nombre', c.nombre) as cliente,
                (
                    SELECT json_agg(json_build_object(
                        'id', d.id, 'producto', json_build_object('id', p.id, 'nombre', p.nombre)
                    )) 
                    FROM gym.detalle_venta d 
                    JOIN gym.producto p ON d.producto_id = p.id
                    WHERE d.venta_id = v.id
                ) as detalles
            FROM gym.venta v
            JOIN gym.cliente c ON v.cliente_id = c.id
            WHERE v.empresa_id = ${empresaId} 
              AND v.sucursal_id = ${sucursalId}
              AND v.creado_at >= ${desde} 
              AND v.creado_at <= ${hasta}
              AND v.estado = 'APLICADA'
            ORDER BY v.creado_at DESC
        `;
    return ventas;
  }

  async getAsistenciaPorHora(
    empresaId: string,
    sucursalId: string,
    fecha: Date,
  ) {
    const inicio = new Date(fecha);
    inicio.setHours(0, 0, 0, 0);
    const fin = new Date(fecha);
    fin.setHours(23, 59, 59, 999);

    // Raw Query
    const resultados = await this.db.sql`
            SELECT EXTRACT(HOUR FROM fecha_hora) as hora, COUNT(*)::integer as cantidad
            FROM gym.asistencia
            WHERE empresa_id = ${empresaId}
            AND sucursal_id = ${sucursalId}
            AND fecha_hora >= ${inicio} AND fecha_hora <= ${fin}
            GROUP BY hora
            ORDER BY hora ASC
        `;

    return resultados.map((r) => ({
      hora: Number(r.hora),
      cantidad: Number(r.cantidad),
    }));
  }
}
