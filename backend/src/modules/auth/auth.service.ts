import { Injectable, UnauthorizedException, ForbiddenException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../common/prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AuthService {
    constructor(
        private prisma: PrismaService,
        private jwtService: JwtService,
        private configService: ConfigService,
    ) { }

    async validateUser(email: string, pass: string, empresaId?: string): Promise<any> {
        const user = await this.prisma.usuario.findFirst({
            where: {
                email: email,
                ...(empresaId ? { empresa_id: empresaId } : {}),
            },
            include: {
                roles: { include: { rol: true } },
                sucursales: { include: { sucursal: true } },
            },
        });

        if (user && user.estado === 'ACTIVO' && (await bcrypt.compare(pass, user.hash))) {
            const { hash, ...result } = user;
            return result;
        }
        return null;
    }

    async login(loginDto: LoginDto) {
        const user = await this.validateUser(loginDto.email, loginDto.password, loginDto.empresaId);
        if (!user) {
            throw new UnauthorizedException('Credenciales inválidas o usuario inactivo');
        }

        const payload = {
            sub: user.id,
            email: user.email,
            tokenVersion: user.token_version,
            empresaId: user.empresa_id
        };

        const accessToken = await this.jwtService.signAsync(payload);
        const refreshToken = await this.jwtService.signAsync(payload, { expiresIn: '7d' });

        await this.prisma.usuario.update({
            where: { id: user.id },
            data: { ultimo_login_at: new Date() },
        });

        return {
            accessToken,
            refreshToken,
            tokenVersion: user.token_version,
            user: {
                id: user.id,
                empresaId: user.empresa_id,
                email: user.email,
                nombre: user.nombre,
                estado: user.estado,
                roles: user.roles.map(r => r.rol.nombre),
                sucursales: user.sucursales.map(s => ({
                    id: s.sucursal.id,
                    empresaId: s.sucursal.empresa_id,
                    nombre: s.sucursal.nombre,
                    direccion: s.sucursal.direccion,
                    estado: s.sucursal.estado,
                })),
            },
        };
    }

    async refresh(refreshTokenDto: RefreshTokenDto) {
        try {
            const payload = await this.jwtService.verifyAsync(refreshTokenDto.refreshToken, {
                secret: this.configService.get('JWT_SECRET'),
            });

            const user = await this.prisma.usuario.findUnique({ where: { id: payload.sub } });
            if (!user || user.estado !== 'ACTIVO' || user.token_version !== payload.tokenVersion) {
                throw new ForbiddenException('Token inválido o usuario inactivo');
            }

            const newPayload = {
                sub: user.id,
                email: user.email,
                tokenVersion: user.token_version,
                empresaId: user.empresa_id
            };

            return {
                accessToken: await this.jwtService.signAsync(newPayload),
                refreshToken: refreshTokenDto.refreshToken,
            };
        } catch (e) {
            throw new ForbiddenException('Invalid refresh token');
        }
    }

    async logout(userId: string) {
        return { message: 'Logged out successfully' };
    }
}
