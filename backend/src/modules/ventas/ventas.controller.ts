import { Controller, Post, Body, UseGuards, Request, BadRequestException } from '@nestjs/common';
import { VentasService } from './ventas.service';
import { AuthGuard } from '@nestjs/passport';

@UseGuards(AuthGuard('jwt'))
@Controller('ventas')
export class VentasController {
    constructor(private readonly ventasService: VentasService) { }

    @Post()
    async create(@Request() req, @Body() body: any) {
        /* 
           Body debe incluir:
           sucursalId: uuid
           cajaId: uuid
           ... resto del payload
        */
        if (!body.sucursalId) {
            throw new BadRequestException('sucursalId es requerido en el body');
        }

        // Opcional: validar que el usuario pertenece a esta sucursal (ya cubierto por lógica de negocio o AuthGuard)

        return this.ventasService.createVenta(
            req.user.empresaId,
            body.sucursalId,
            req.user.userId,
            body
        );
    }
}
