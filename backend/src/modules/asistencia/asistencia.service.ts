import { Injectable, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { ValidarAccesoDto } from './dto/validar-acceso.dto';

@Injectable()
export class AsistenciaService {
    constructor(private prisma: PrismaService) { }

    async validarAcceso(empresaId: string, usuarioId: string, dto: ValidarAccesoDto) {
        // 1. Verificar Cliente
        const cliente = await this.prisma.cliente.findUnique({
            where: { id: dto.clienteId },
            include: {
                membresias: {
                    where: { estado: 'ACTIVA', fin: { gte: new Date() } },
                    include: { plan: true },
                    orderBy: { fin: 'desc' },
                    take: 1
                }
            }
        });

        if (!cliente || cliente.estado !== 'ACTIVO') {
            throw new ForbiddenException('Cliente no encontrado o inactivo');
        }

        const membresia = cliente.membresias[0];
        let resultado = 'DENEGADO';
        let motivo = 'SIN_MEMBRESIA'; // o "VENCIDA"

        if (membresia) {
            if (membresia.sucursal_id !== dto.sucursalId) {
                // Validar acceso multisede real
                if (membresia.plan.multisede) {
                    resultado = 'PERMITIDO';
                } else {
                    resultado = 'DENEGADO';
                    motivo = 'SUCURSAL_INCORRECTA';
                }
            } else {
                resultado = 'PERMITIDO';
            }

            // Validar Visitas (si es por visitas)
            if (resultado === 'PERMITIDO' && membresia.plan.tipo === 'VISITAS') {
                if (membresia.visitas_restantes !== null && membresia.visitas_restantes <= 0) {
                    resultado = 'DENEGADO';
                    motivo = 'SIN_VISITAS';
                }
            }
        }

        // 2. Registrar Asistencia
        const asistencia = await this.prisma.asistencia.create({
            data: {
                empresa: { connect: { id: empresaId } },
                sucursal: { connect: { id: dto.sucursalId } },
                cliente: { connect: { id: dto.clienteId } },
                usuario: { connect: { id: usuarioId } },
                resultado,
                nota: dto.notas || motivo,
            }
        });

        // 3. Decrementar visita si aplica (Atómico para evitar sobre-uso en concurrencia)
        if (resultado === 'PERMITIDO' && membresia?.plan.tipo === 'VISITAS') {
            const updateMemb = await this.prisma.membresiaCliente.updateMany({
                where: {
                    id: membresia.id,
                    visitas_restantes: { gt: 0 }
                },
                data: { visitas_restantes: { decrement: 1 } }
            });

            if (updateMemb.count === 0) {
                // Si llegamos aquí, alguien más usó la última visita entre el paso 1 y el 3
                await this.prisma.asistencia.update({
                    where: { id: asistencia.id },
                    data: { resultado: 'DENEGADO', nota: 'SIN_VISITAS_CONCURRENTE' }
                });
                return {
                    acceso: false,
                    motivo: 'SIN_VISITAS',
                    cliente: { nombre: cliente.nombre, foto: cliente.foto_url },
                    membresia: null,
                    asistenciaId: asistencia.id
                };
            }
        }

        return {
            acceso: resultado === 'PERMITIDO',
            motivo: resultado === 'PERMITIDO' ? 'OK' : motivo,
            cliente: { nombre: cliente.nombre, foto: cliente.foto_url },
            membresia: membresia ? { plan: membresia.plan.nombre, fin: membresia.fin } : null,
            asistenciaId: asistencia.id
        };
    }

    async registrarSalida(asistenciaId: string) {
        return this.prisma.asistencia.update({
            where: { id: asistenciaId },
            data: { fecha_salida: new Date() }
        });
    }

    async findRecientes(empresaId: string, sucursalId: string, limit: number = 10) {
        return this.prisma.asistencia.findMany({
            where: { empresa_id: empresaId, sucursal_id: sucursalId },
            include: { cliente: true },
            orderBy: { fecha_hora: 'desc' },
            take: Number(limit) || 10
        });
    }
}
