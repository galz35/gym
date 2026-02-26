import { Controller, Get, Post, Body, Param, Query, UseGuards, Request, Patch } from '@nestjs/common';
import { MembresiasService } from './membresias.service';
import { AuthGuard } from '@nestjs/passport';

@UseGuards(AuthGuard('jwt'))
@Controller('membresias')
export class MembresiasController {
    constructor(private readonly membresiasService: MembresiasService) { }

    @Get()
    async findAll(@Request() req, @Query('sucursalId') sucursalId: string) {
        return this.membresiasService.findAll(req.user.empresaId, sucursalId);
    }

    @Post()
    async create(@Request() req, @Body() dto: any) {
        return this.membresiasService.create(req.user.empresaId, dto);
    }

    @Post(':id/renovar')
    async renovar(@Param('id') id: string, @Body() dto: any) {
        return this.membresiasService.renovar(id, dto);
    }

    @Patch(':id/congelar')
    async congelar(@Param('id') id: string) {
        return this.membresiasService.setStatus(id, 'CONGELADA');
    }

    @Patch(':id/activar')
    async activar(@Param('id') id: string) {
        return this.membresiasService.setStatus(id, 'ACTIVA');
    }

    @Patch(':id')
    async update(@Param('id') id: string, @Body() dto: any) {
        return this.membresiasService.setStatus(id, dto.estado);
    }
}
