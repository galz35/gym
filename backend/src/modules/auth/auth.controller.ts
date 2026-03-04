import {
  Controller,
  Post,
  Body,
  Get,
  UseGuards,
  Request,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { AuthGuard } from '@nestjs/passport';
import { DatabaseService } from '../../common/database/database.service';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly db: DatabaseService,
  ) {}

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
    const [user] = await this.db.sql`
            SELECT u.id, u.empresa_id, u.email, u.nombre, u.estado,
                   (SELECT json_agg(r.nombre) 
                    FROM gym.usuario_rol ur 
                    JOIN gym.rol r ON ur.rol_id = r.id 
                    WHERE ur.usuario_id = u.id) as roles,
                   (SELECT json_agg(json_build_object(
                       'id', s.id,
                       'empresaId', s.empresa_id,
                       'nombre', s.nombre,
                       'direccion', s.direccion,
                       'estado', s.estado
                   ))
                    FROM gym.usuario_sucursal us
                    JOIN gym.sucursal s ON us.sucursal_id = s.id
                    WHERE us.usuario_id = u.id) as sucursales
            FROM gym.usuario u
            WHERE u.id = ${req.user.userId}
        `;

    if (!user) return req.user;

    return {
      id: user.id,
      empresaId: user.empresa_id,
      email: user.email,
      nombre: user.nombre,
      estado: user.estado,
      roles: user.roles || [],
      sucursales: user.sucursales || [],
    };
  }
}
