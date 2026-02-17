import { Controller, Post, Body, Get, UseGuards, Request } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { AuthGuard } from '@nestjs/passport';
import { PrismaService } from '../../common/prisma/prisma.service';

@Controller('auth')
export class AuthController {
    constructor(
        private readonly authService: AuthService,
        private readonly prisma: PrismaService,
    ) { }

    @Post('login')
    async login(@Body() loginDto: LoginDto) {
        return this.authService.login(loginDto);
    }

    @Post('refresh')
    async refresh(@Body() refreshTokenDto: RefreshTokenDto) {
        return this.authService.refresh(refreshTokenDto);
    }

    @UseGuards(AuthGuard('jwt'))
    @Post('logout')
    async logout(@Request() req) {
        return this.authService.logout(req.user.userId);
    }

    @UseGuards(AuthGuard('jwt'))
    @Get('profile')
    async getProfile(@Request() req) {
        const user = await this.prisma.usuario.findUnique({
            where: { id: req.user.userId },
            include: {
                roles: { include: { rol: true } },
                sucursales: { include: { sucursal: true } },
            },
        });
        if (!user) return req.user;
        const { hash, ...rest } = user;
        return {
            id: rest.id,
            empresaId: rest.empresa_id,
            email: rest.email,
            nombre: rest.nombre,
            estado: rest.estado,
            roles: rest.roles.map(r => r.rol.nombre),
            sucursales: rest.sucursales.map(s => ({
                id: s.sucursal.id,
                empresaId: s.sucursal.empresa_id,
                nombre: s.sucursal.nombre,
                direccion: s.sucursal.direccion,
                estado: s.sucursal.estado,
            })),
        };
    }
}
