import { Controller, Get, ServiceUnavailableException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Controller('healthz')
export class HealthController {
    private readonly logger = new Logger(HealthController.name);

    constructor(private readonly prisma: PrismaService) { }

    @Get()
    async check() {
        try {
            this.logger.log('Keep-Alive ping received');
            // Barato: SELECT 1 (Keep-alive según guía)
            await this.prisma.$queryRaw`SELECT 1`;
            return {
                status: 'ok',
                timestamp: new Date().toISOString(),
                database: 'connected'
            };
        } catch (error) {
            this.logger.error(`Health check failed: ${error.message}`);
            throw new ServiceUnavailableException({
                status: 'error',
                database: 'disconnected',
                error: error.message
            });
        }
    }
}
