import { Injectable } from '@nestjs/common';
import { PrismaService } from './common/prisma/prisma.service'; // Verify path

@Injectable()
export class AppService {
  constructor(private prisma: PrismaService) { }

  getHello(): string {
    return 'Hello World!';
  }

  async checkHealth() {
    try {
      // Cast to any because local generation failed, but Render will generate it
      const prisma = this.prisma as any;
      let status = await prisma.sistemaStatus.findUnique({ where: { id: 1 } });
      if (!status) {
        status = await prisma.sistemaStatus.create({
          data: {
            id: 1,
            activo: true,
            nombre: 'BASE_ACTIVA',
          },
        });
      }
      return {
        status: 'ok',
        system: status,
        timestamp: new Date(),
      };
    } catch (e) {
      return {
        status: 'error',
        message: e.message,
        timestamp: new Date(),
      };
    }
  }
}
