import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { PullSyncDto } from './dto/pull-sync.dto';
import { PushSyncDto, SyncEventDto } from './dto/push-sync.dto';
import { VentasService } from '../ventas/ventas.service';
import { CajaService } from '../caja/caja.service';
import { InventarioService } from '../inventario/inventario.service';

interface SyncResult {
    idLocal: string;
    status: 'OK' | 'ERROR';
    error?: string;
}

@Injectable()
export class SyncService {
    private readonly logger = new Logger(SyncService.name);

    constructor(
        private prisma: PrismaService,
        private ventasService: VentasService,
        private cajaService: CajaService,
        private inventarioService: InventarioService,
    ) { }

    async pull(empresaId: string, query: PullSyncDto) {
        const { desdeSeq, sucursalId } = query;
        const limit = 2000;

        // @ts-ignore
        const cambios = await this.prisma.cambioLog.findMany({
            where: {
                empresa_id: empresaId,
                seq: { gt: desdeSeq },
                OR: [
                    { sucursal_id: null },
                    { sucursal_id: sucursalId || undefined },
                ],
            },
            orderBy: { seq: 'asc' },
            take: limit,
        });

        const lastSeq = cambios.length > 0 ? Number(cambios[cambios.length - 1].seq) : desdeSeq;

        return {
            serverTimeUtc: new Date().toISOString(),
            hastaSeq: lastSeq,
            cambios,
        };
    }

    async push(empresaId: string, userId: string, pushDto: PushSyncDto) {
        const { deviceId, requestId, eventos } = pushDto;

        // 1. Idempotencia Request
        // @ts-ignore
        const existingRequest = await this.prisma.syncRequestProcesado.findUnique({
            where: {
                empresa_id_device_id_request_id: {
                    empresa_id: empresaId,
                    device_id: deviceId,
                    request_id: requestId,
                },
            },
        });

        if (existingRequest) {
            return { status: 'OK', message: 'Already processed' };
        }

        const results: SyncResult[] = [];

        // 2. Procesar Eventos
        for (const evento of eventos) {
            try {
                await this.processEvent(empresaId, userId, deviceId, evento);
                results.push({ idLocal: evento.idLocal, status: 'OK' });
            } catch (error) {
                this.logger.error(`Error processing event ${evento.idLocal}: ${error.message}`, error.stack);
                results.push({ idLocal: evento.idLocal, status: 'ERROR', error: error.message });
            }
        }

        // 3. Registrar Request Procesado
        // @ts-ignore
        await this.prisma.syncRequestProcesado.create({
            data: {
                empresa_id: empresaId,
                usuario_id: userId,
                device_id: deviceId,
                request_id: requestId,
            },
        });

        return { status: 'PARTIAL_OK', results };
    }

    private async processEvent(empresaId: string, userId: string, deviceId: string, event: SyncEventDto) {
        // Idempotencia Evento
        // @ts-ignore
        const existingEvent = await this.prisma.eventoProcesado.findUnique({
            where: {
                empresa_id_device_id_event_id: {
                    empresa_id: empresaId,
                    device_id: deviceId,
                    event_id: event.eventId,
                },
            },
        });

        if (existingEvent) return; // Ya procesado

        // Procesar según tipo
        switch (event.tipo) {
            case 'VENTA':
                if (event.accion === 'CREAR') {
                    await this.ventasService.createVenta(empresaId, event.payload.sucursalId, userId, event.payload);
                }
                break;

            case 'CLIENTE':
                if (event.accion === 'UPSERT') {
                    // @ts-ignore
                    await this.prisma.cliente.upsert({
                        where: { id: event.payload.id || 'new' },
                        update: {
                            nombre: event.payload.nombre,
                            telefono: event.payload.telefono,
                            email: event.payload.email,
                            documento: event.payload.documento,
                            foto_url: event.payload.foto_url,
                            estado: event.payload.estado,
                            actualizado_at: new Date()
                        },
                        create: {
                            ...event.payload,
                            empresa_id: empresaId,
                            creado_at: new Date()
                        },
                    });
                }
                break;

            case 'ASISTENCIA':
                if (event.accion === 'CREAR') {
                    // @ts-ignore
                    await this.prisma.asistencia.create({
                        data: {
                            ...event.payload,
                            empresa_id: empresaId,
                            usuario_id: userId,
                            fecha_hora: event.payload.fecha_hora || new Date()
                        },
                    });
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
                    await this.inventarioService.registrarEntrada(empresaId, userId, event.payload);
                }
                break;

            default:
                this.logger.warn(`Evento desconocido: ${event.tipo}`);
        }

        // Registrar evento procesado
        // @ts-ignore
        await this.prisma.eventoProcesado.create({
            data: {
                empresa_id: empresaId,
                device_id: deviceId,
                event_id: event.eventId,
            },
        });
    }
}
