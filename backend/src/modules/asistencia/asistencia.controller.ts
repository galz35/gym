import { Controller, Post, Body, Param, UseGuards, Request, Get } from '@nestjs/common';
import { AsistenciaService } from './asistencia.service';
import { ValidarAccesoDto } from './dto/validar-acceso.dto';
import { AuthGuard } from '@nestjs/passport';

@UseGuards(AuthGuard('jwt'))
@Controller('asistencia')
export class AsistenciaController {
    constructor(private readonly asistenciaService: AsistenciaService) { }

    @Post('checkin')
    async checkin(@Request() req, @Body() dto: ValidarAccesoDto) {
        return this.asistenciaService.validarAcceso(req.user.empresaId, req.user.userId, dto);
    }

    @Post('checkout/:id')
    async checkout(@Param('id') id: string) {
        return this.asistenciaService.registrarSalida(id);
    }
}
