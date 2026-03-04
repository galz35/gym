import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { DatabaseService } from '../../../common/database/database.service';

@Injectable()
export class ActivoGuard implements CanActivate {
  constructor(private db: DatabaseService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) return false;

    // 1.4 Reglas de bloqueo inmediato (Extras)
    const [dbUser] = await this.db.sql`
            SELECT estado, token_version FROM gym.usuario WHERE id = ${user.sub}
        `;

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
