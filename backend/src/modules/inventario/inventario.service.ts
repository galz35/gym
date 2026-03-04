import { Injectable, BadRequestException } from '@nestjs/common';
import { DatabaseService } from '../../common/database/database.service';
import { CreateEntradaDto, CreateProductoDto } from './dto/inventario.dto';

@Injectable()
export class InventarioService {
    constructor(private db: DatabaseService) { }

    async findAllProductos(empresaId: string) {
        return this.db.sql`
            SELECT p.*,
                (SELECT json_agg(row_to_json(inv)) 
                 FROM gym.inventario_sucursal inv 
                 WHERE inv.producto_id = p.id) as inventarios
            FROM gym.producto p
            WHERE p.empresa_id = ${empresaId} AND p.estado = 'ACTIVO'
        `;
    }

    async findStockSucursal(sucursalId: string) {
        return this.db.sql`
            SELECT i.*, row_to_json(p) as producto
            FROM gym.inventario_sucursal i
            JOIN gym.producto p ON i.producto_id = p.id
            WHERE i.sucursal_id = ${sucursalId}
        `;
    }

    async createProducto(empresaId: string, dto: CreateProductoDto) {
        const precioCentavos = Math.round(dto.precio * 100);
        const costoCentavos = Math.round(dto.costo * 100);

        const [producto] = await this.db.sql`
            INSERT INTO gym.producto (empresa_id, nombre, categoria, precio_centavos, costo_centavos, estado)
            VALUES (${empresaId}, ${dto.nombre}, ${dto.categoria || null}, ${precioCentavos}, ${costoCentavos}, 'ACTIVO')
            RETURNING *
        `;
        return producto;
    }

    async registrarEntrada(empresaId: string, usuarioId: string, dto: CreateEntradaDto) {
        return await this.db.sql.begin(async (sql: any) => {
            const [inventario] = await sql`
                INSERT INTO gym.inventario_sucursal (empresa_id, sucursal_id, producto_id, existencia)
                VALUES (${empresaId}, ${dto.sucursalId}, ${dto.productoId}, ${dto.cantidad})
                ON CONFLICT (sucursal_id, producto_id)
                DO UPDATE SET existencia = gym.inventario_sucursal.existencia + EXCLUDED.existencia, actualizado_at = NOW()
                RETURNING *
            `;

            const [movimiento] = await sql`
                INSERT INTO gym.movimiento_inventario (empresa_id, sucursal_id, producto_id, usuario_id, tipo, cantidad, ref_tipo, payload_json)
                VALUES (${empresaId}, ${dto.sucursalId}, ${dto.productoId}, ${usuarioId}, 'ENTRADA', ${dto.cantidad}, 'ABASTECIMIENTO', ${sql.json(dto.notas ? { notas: dto.notas } : {})})
                RETURNING *
            `;

            return movimiento;
        });
    }

    async registrarMerma(empresaId: string, usuarioId: string, dto: CreateEntradaDto) {
        return await this.db.sql.begin(async (sql: any) => {
            const [inventario] = await sql`
                UPDATE gym.inventario_sucursal
                SET existencia = existencia - ${dto.cantidad}, actualizado_at = NOW()
                WHERE sucursal_id = ${dto.sucursalId} 
                  AND producto_id = ${dto.productoId} 
                  AND existencia >= ${dto.cantidad}
                RETURNING *
            `;

            if (!inventario) {
                throw new BadRequestException('Inventario insuficiente o producto no encontrado para procesar la merma');
            }

            const [movimiento] = await sql`
                INSERT INTO gym.movimiento_inventario (empresa_id, sucursal_id, producto_id, usuario_id, tipo, cantidad, ref_tipo, payload_json)
                VALUES (${empresaId}, ${dto.sucursalId}, ${dto.productoId}, ${usuarioId}, 'SALIDA', ${dto.cantidad}, 'MERMA', ${sql.json(dto.notas ? { notas: dto.notas } : {})})
                RETURNING *
            `;

            return movimiento;
        });
    }

    async getKardex(empresaId: string, sucursalId: string, productoId: string) {
        return this.db.sql`
            SELECT m.*, json_build_object('nombre', u.nombre) as usuario
            FROM gym.movimiento_inventario m
            LEFT JOIN gym.usuario u ON m.usuario_id = u.id
            WHERE m.empresa_id = ${empresaId}
              AND m.sucursal_id = ${sucursalId}
              AND m.producto_id = ${productoId}
            ORDER BY m.creado_at DESC
        `;
    }

    async getTopProductos(empresaId: string, sucursalId: string) {
        const fechaInicio = new Date();
        fechaInicio.setDate(fechaInicio.getDate() - 30);

        const top = await this.db.sql`
            SELECT d.producto_id, sum(d.cantidad)::integer as total_vendido
            FROM gym.detalle_venta d
            JOIN gym.venta v ON d.venta_id = v.id
            WHERE v.empresa_id = ${empresaId}
              AND v.sucursal_id = ${sucursalId}
              AND v.creado_at >= ${fechaInicio}
            GROUP BY d.producto_id
            ORDER BY total_vendido DESC
            LIMIT 20
        `;

        if (top.length === 0) return [];

        const productIds = top.map(t => t.producto_id);

        const productos = await this.db.sql`
            SELECT * FROM gym.producto WHERE id IN ${this.db.sql(productIds)}
        `;

        return top.map(t => {
            const p = productos.find((prod: any) => prod.id === t.producto_id);
            return {
                ...p,
                ventas_periodo: Number(t.total_vendido || 0)
            };
        });
    }
}
