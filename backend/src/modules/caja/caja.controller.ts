import { Controller, Get, Post, Put, Body, Param, UseGuards, Request } from '@nestjs/common';
import { CajaService } from './caja.service';
import { OpenCajaDto, CloseCajaDto } from './dto/actions-caja.dto';
import { AuthGuard } from '@nestjs/passport';

@UseGuards(AuthGuard('jwt'))
@Controller('caja')
export class CajaController {
    constructor(private readonly cajaService: CajaService) { }

    @Get('abierta')
    async getCajaAbierta(@Request() req) {
        return this.cajaService.findAbierta(req.user.empresaId, req.user.sucursalId, req.user.userId);
    }

    @Get('estado/:sucursalId')
    async getEstadoCaja(@Request() req, @Param('sucursalId') sucursalId: string) {
        // Returns active boxes for the sucursal or general status
        return this.cajaService.findAllAbiertas(req.user.empresaId, sucursalId);
    }

    @Post('abrir')
    async abrir(@Request() req, @Body() dto: OpenCajaDto) {
        return this.cajaService.abrir(req.user.empresaId, req.user.userId, dto);
    }

    @Post('cerrar/:id')
    async cerrar(@Param('id') id: string, @Body() dto: CloseCajaDto) {
        return this.cajaService.cerrar(id, dto);
    }
}
