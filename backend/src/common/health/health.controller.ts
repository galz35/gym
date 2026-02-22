import { Controller, Get, ServiceUnavailableException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Controller('health')
export class HealthController {
    constructor(private prisma: PrismaService) { }

    @Get('ping')
    async ping() {
        try {
            // Test DB connection and keep-alive
            let status = await this.prisma.sistemaStatus.findFirst();
            if (!status) {
                status = await this.prisma.sistemaStatus.create({
                    data: { id: 1, nombre: 'BASE_ACTIVA', activo: true }
                });
            } else {
                await this.prisma.sistemaStatus.update({
                    where: { id: status.id },
                    data: { timestamp: new Date() }
                });
            }

            return {
                status: 'ok',
                system: status.nombre,
                database: 'connected',
                timestamp: new Date().toISOString()
            };
        } catch (error) {
            throw new ServiceUnavailableException({
                status: 'error',
                database: 'disconnected',
                error: error.message
            });
        }
    }
}
