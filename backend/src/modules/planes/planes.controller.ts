import { Controller, Get, Post, Put, Body, Param, UseGuards, Request, Query } from '@nestjs/common';
import { PlanesService } from './planes.service';
import { CreatePlanDto, UpdatePlanDto } from './dto/create-plan.dto';
import { AuthGuard } from '@nestjs/passport';

@UseGuards(AuthGuard('jwt'))
@Controller('planes')
export class PlanesController {
    constructor(private readonly planesService: PlanesService) { }

    @Get()
    async findAll(@Request() req, @Query('sucursalId') sucursalId?: string) {
        return this.planesService.findAll(req.user.empresaId, sucursalId);
    }

    @Post()
    async create(@Request() req, @Body() dto: CreatePlanDto) {
        // Si usuario tiene permiso (Dueño/Admin)
        return this.planesService.create(req.user.empresaId, dto);
    }

    @Put(':id')
    async update(@Param('id') id: string, @Body() dto: UpdatePlanDto) {
        return this.planesService.update(id, dto);
    }
}
