import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';

@Injectable()
export class RolesGuard implements CanActivate {
    constructor(private reflector: Reflector) { }

    canActivate(context: ExecutionContext): boolean {
        const roles = this.reflector.get<string[]>('roles', context.getHandler());
        if (!roles) return true; // Si no hay roles definidos, permite acceso (o deny all por defecto?)

        const request = context.switchToHttp().getRequest();
        const user = request.user;
        if (!user || !user.roles) return false;

        // Verificar si el usuario tiene al menos UNO de los roles requeridos
        return roles.some(role => user.roles.includes(role));
    }
}
