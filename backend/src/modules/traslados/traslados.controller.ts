import { Controller, Post, Body, UseGuards, Request, Get, Param, Put } from '@nestjs/common';
import { TrasladosService } from './traslados.service';
import { CreateTrasladoDto } from './dto/traslado.dto';
import { AuthGuard } from '@nestjs/passport';

@UseGuards(AuthGuard('jwt'))
@Controller('traslados')
export class TrasladosController {
    constructor(private readonly trasladosService: TrasladosService) { }

    @Post()
    async crear(@Request() req, @Body() dto: CreateTrasladoDto) {
        return this.trasladosService.crear(req.user.empresaId, req.user.userId, dto);
    }

    @Get('pendientes/:sucursalId')
    async pendientes(@Request() req, @Param('sucursalId') sucursalId: string) {
        return this.trasladosService.findAllPendientes(req.user.empresaId, sucursalId);
    }

    @Put('recibir/:id')
    async recibir(@Request() req, @Param('id') id: string) {
        return this.trasladosService.recibir(id, req.user.userId);
    }
}
