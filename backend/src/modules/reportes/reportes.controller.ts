import { Controller, Get, Query, UseGuards, Request } from '@nestjs/common';
import { ReportesService } from './reportes.service';
import { AuthGuard } from '@nestjs/passport';

@UseGuards(AuthGuard('jwt'))
@Controller('reportes')
export class ReportesController {
    constructor(private readonly reportesService: ReportesService) { }

    @Get('resumen-dia')
    async getResumenDia(@Request() req, @Query('fecha') fecha: string, @Query('sucursalId') sucursalId: string) {
        const date = fecha ? new Date(fecha) : new Date();
        return this.reportesService.getResumenDia(req.user.empresaId, sucursalId, date);
    }

    @Get('vencimientos')
    async getVencimientos(@Request() req, @Query('dias') dias: number, @Query('sucursalId') sucursalId: string) {
        return this.reportesService.getVencimientos(req.user.empresaId, sucursalId, dias || 7);
    }

    @Get('ventas')
    async getVentas(@Request() req, @Query('desde') desde: string, @Query('hasta') hasta: string, @Query('sucursalId') sucursalId: string) {
        return this.reportesService.getVentasRango(req.user.empresaId, sucursalId, new Date(desde), new Date(hasta));
    }

    @Get('asistencia-hora')
    async getAsistenciaHora(@Request() req, @Query('fecha') fecha: string, @Query('sucursalId') sucursalId: string) {
        const date = fecha ? new Date(fecha) : new Date();
        return this.reportesService.getAsistenciaPorHora(req.user.empresaId, sucursalId, date);
    }
}
