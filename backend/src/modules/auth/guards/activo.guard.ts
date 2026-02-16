import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../../common/prisma/prisma.service';

@Injectable()
export class ActivoGuard implements CanActivate {
    constructor(private prisma: PrismaService) { }

    async canActivate(context: ExecutionContext): Promise<boolean> {
        const request = context.switchToHttp().getRequest();
        const user = request.user;

        if (!user) return false;

        // 1.4 Reglas de bloqueo inmediato (Extras)
        const dbUser = await this.prisma.usuario.findUnique({
            where: { id: user.sub },
        });

        if (!dbUser || dbUser.estado !== 'ACTIVO') {
            throw new ForbiddenException('USUARIO_INACTIVO');
        }

        // Validar token_version
        if (user.tokenVersion !== dbUser.token_version) {
            throw new ForbiddenException('SESSION_EXPIRED');
        }

        return true;
    }
}
