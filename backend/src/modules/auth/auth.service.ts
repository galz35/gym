import { Injectable, UnauthorizedException, ForbiddenException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { DatabaseService } from '../../common/database/database.service';
import * as bcrypt from 'bcrypt';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AuthService {
    constructor(
        private db: DatabaseService,
        private jwtService: JwtService,
        private configService: ConfigService,
    ) { }

    async validateUser(email: string, pass: string, empresaId?: string): Promise<any> {
        let rows;
        if (empresaId) {
            rows = await this.db.sql`
                SELECT u.*, 
                    (SELECT json_agg(json_build_object('rol', json_build_object('nombre', r.nombre))) 
                     FROM gym.usuario_rol ur JOIN gym.rol r ON ur.rol_id = r.id WHERE ur.usuario_id = u.id) as roles,
                    (SELECT json_agg(json_build_object('sucursal', row_to_json(s))) 
                     FROM gym.usuario_sucursal us JOIN gym.sucursal s ON us.sucursal_id = s.id WHERE us.usuario_id = u.id) as sucursales
                FROM gym.usuario u
                WHERE u.email = ${email} AND u.empresa_id = ${empresaId}
            `;
        } else {
            rows = await this.db.sql`
                SELECT u.*, 
                    (SELECT json_agg(json_build_object('rol', json_build_object('nombre', r.nombre))) 
                     FROM gym.usuario_rol ur JOIN gym.rol r ON ur.rol_id = r.id WHERE ur.usuario_id = u.id) as roles,
                    (SELECT json_agg(json_build_object('sucursal', row_to_json(s))) 
                     FROM gym.usuario_sucursal us JOIN gym.sucursal s ON us.sucursal_id = s.id WHERE us.usuario_id = u.id) as sucursales
                FROM gym.usuario u
                WHERE u.email = ${email}
            `;
        }

        const user = rows[0];

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

        await this.db.sql`
            UPDATE gym.usuario 
            SET ultimo_login_at = NOW() 
            WHERE id = ${user.id}
        `;

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
                roles: user.roles ? user.roles.map((r: any) => r.rol?.nombre) : [],
                sucursales: user.sucursales ? user.sucursales.map((s: any) => ({
                    id: s.sucursal?.id,
                    empresaId: s.sucursal?.empresa_id,
                    nombre: s.sucursal?.nombre,
                    direccion: s.sucursal?.direccion,
                    estado: s.sucursal?.estado,
                })) : [],
            },
        };
    }

    async refresh(refreshTokenDto: RefreshTokenDto) {
        try {
            const payload = await this.jwtService.verifyAsync(refreshTokenDto.refreshToken, {
                secret: this.configService.get('JWT_SECRET'),
            });

            const [user] = await this.db.sql`SELECT * FROM gym.usuario WHERE id = ${payload.sub}`;

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
