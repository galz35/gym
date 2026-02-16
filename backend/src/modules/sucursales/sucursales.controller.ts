import { Controller, Get, Post, Put, Body, Param, UseGuards, Request } from '@nestjs/common';
import { SucursalesService } from './sucursales.service';
import { CreateSucursalDto, UpdateSucursalDto } from './dto/create-sucursal.dto';
import { AuthGuard } from '@nestjs/passport';

@UseGuards(AuthGuard('jwt'))
@Controller('sucursales')
export class SucursalesController {
    constructor(private readonly sucursalesService: SucursalesService) { }

    @Get()
    async findAll(@Request() req) {
        // Assuming req.user has empresaId from AuthService.login logic
        return this.sucursalesService.findAll(req.user.empresaId);
    }

    @Post()
    async create(@Body() createSucursalDto: CreateSucursalDto) {
        return this.sucursalesService.create(createSucursalDto);
    }

    @Put(':id')
    async update(@Param('id') id: string, @Body() dto: UpdateSucursalDto) {
        return this.sucursalesService.update(id, dto);
    }
}
