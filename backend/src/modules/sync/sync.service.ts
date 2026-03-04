import { Injectable, Logger } from '@nestjs/common';
import { DatabaseService } from '../../common/database/database.service';
import { PullSyncDto } from './dto/pull-sync.dto';
import { PushSyncDto, SyncEventDto } from './dto/push-sync.dto';
import { VentasService } from '../ventas/ventas.service';
import { CajaService } from '../caja/caja.service';
import { InventarioService } from '../inventario/inventario.service';

export interface SyncResult {
  idLocal: string;
  status: 'OK' | 'ERROR';
  error?: string;
}

@Injectable()
export class SyncService {
  private readonly logger = new Logger(SyncService.name);

  constructor(
    private db: DatabaseService,
    private ventasService: VentasService,
    private cajaService: CajaService,
    private inventarioService: InventarioService,
  ) {}

  async pull(empresaId: string, query: PullSyncDto) {
    const { desdeSeq, sucursalId } = query;
    const limit = 2000;

    let cambios;
    if (sucursalId) {
      cambios = await this.db.sql`
                SELECT * FROM gym.cambio_log
                WHERE empresa_id = ${empresaId}
                  AND seq > ${desdeSeq}
                  AND (sucursal_id IS NULL OR sucursal_id = ${sucursalId})
                ORDER BY seq ASC
                LIMIT ${limit}
            `;
    } else {
      cambios = await this.db.sql`
                SELECT * FROM gym.cambio_log
                WHERE empresa_id = ${empresaId}
                  AND seq > ${desdeSeq}
                  AND sucursal_id IS NULL
                ORDER BY seq ASC
                LIMIT ${limit}
            `;
    }

    const lastSeq =
      cambios.length > 0 ? Number(cambios[cambios.length - 1].seq) : desdeSeq;

    return {
      serverTimeUtc: new Date().toISOString(),
      hastaSeq: lastSeq,
      cambios,
    };
  }

  async push(empresaId: string, userId: string, pushDto: PushSyncDto) {
    const { deviceId, requestId, eventos } = pushDto;

    // 1. Idempotencia Request
    const [existingRequest] = await this.db.sql`
            SELECT id FROM gym.sync_request_procesado
            WHERE empresa_id = ${empresaId}
              AND device_id = ${deviceId}
              AND request_id = ${requestId}
        `;

    if (existingRequest) {
      return { status: 'OK', message: 'Already processed' };
    }

    const results: SyncResult[] = [];

    // 2. Procesar Eventos
    for (const evento of eventos) {
      try {
        await this.processEvent(empresaId, userId, deviceId, evento);
        results.push({ idLocal: evento.idLocal, status: 'OK' });
      } catch (error: any) {
        this.logger.error(
          `Error processing event ${evento.idLocal}: ${error.message}`,
          error.stack,
        );
        results.push({
          idLocal: evento.idLocal,
          status: 'ERROR',
          error: error.message,
        });
      }
    }

    // 3. Registrar Request Procesado
    await this.db.sql`
            INSERT INTO gym.sync_request_procesado (empresa_id, usuario_id, device_id, request_id)
            VALUES (${empresaId}, ${userId}, ${deviceId}, ${requestId})
        `;

    return { status: 'PARTIAL_OK', results };
  }

  private async processEvent(
    empresaId: string,
    userId: string,
    deviceId: string,
    event: SyncEventDto,
  ) {
    // Idempotencia Evento
    const [existingEvent] = await this.db.sql`
            SELECT id FROM gym.evento_procesado
            WHERE empresa_id = ${empresaId}
              AND device_id = ${deviceId}
              AND event_id = ${event.eventId}
        `;

    if (existingEvent) return; // Ya procesado

    // Procesar según tipo
    switch (event.tipo) {
      case 'VENTA':
        if (event.accion === 'CREAR') {
          await this.ventasService.createVenta(
            empresaId,
            event.payload.sucursalId,
            userId,
            event.payload,
          );
        }
        break;

      case 'CLIENTE':
        if (event.accion === 'UPSERT') {
          if (event.payload.id) {
            await this.db.sql`
                           INSERT INTO gym.cliente (id, empresa_id, nombre, telefono, email, documento, foto_url, estado, creado_at)
                           VALUES (${event.payload.id}, ${empresaId}, ${event.payload.nombre}, ${event.payload.telefono || null}, ${event.payload.email || null}, ${event.payload.documento || null}, ${event.payload.foto_url || null}, ${event.payload.estado || 'ACTIVO'}, NOW())
                           ON CONFLICT (id) DO UPDATE 
                           SET nombre = EXCLUDED.nombre,
                               telefono = EXCLUDED.telefono,
                               email = EXCLUDED.email,
                               documento = EXCLUDED.documento,
                               foto_url = EXCLUDED.foto_url,
                               estado = EXCLUDED.estado,
                               actualizado_at = NOW()
                       `;
          } else {
            await this.db.sql`
                           INSERT INTO gym.cliente (empresa_id, nombre, telefono, email, documento, foto_url, estado, creado_at)
                           VALUES (${empresaId}, ${event.payload.nombre}, ${event.payload.telefono || null}, ${event.payload.email || null}, ${event.payload.documento || null}, ${event.payload.foto_url || null}, ${event.payload.estado || 'ACTIVO'}, NOW())
                       `;
          }
        }
        break;

      case 'ASISTENCIA':
        if (event.accion === 'CREAR') {
          await this.db.sql`
                        INSERT INTO gym.asistencia (empresa_id, sucursal_id, cliente_id, usuario_id, resultado, motivo, notas, fecha_hora)
                        VALUES (${empresaId}, ${event.payload.sucursal_id}, ${event.payload.cliente_id}, ${userId}, ${event.payload.resultado}, ${event.payload.motivo || null}, ${event.payload.notas || null}, ${event.payload.fecha_hora || this.db.sql`NOW()`})
                    `;
        }
        break;

      case 'CAJA':
        if (event.accion === 'ABRIR') {
          await this.cajaService.abrir(empresaId, userId, event.payload);
        } else if (event.accion === 'CERRAR') {
          // event.payload should contain the id of the caja record
          await this.cajaService.cerrar(event.payload.id, event.payload);
        }
        break;

      case 'INVENTARIO':
        if (event.accion === 'ENTRADA') {
          await this.inventarioService.registrarEntrada(
            empresaId,
            userId,
            event.payload,
          );
        }
        break;

      default:
        this.logger.warn(`Evento desconocido: ${event.tipo}`);
    }

    // Registrar evento procesado
    await this.db.sql`
            INSERT INTO gym.evento_procesado (empresa_id, device_id, event_id)
            VALUES (${empresaId}, ${deviceId}, ${event.eventId})
        `;
  }
}
