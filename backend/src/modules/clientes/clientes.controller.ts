import { Controller, Get, Post, Put, Body, Param, Query, UseGuards, Request, UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ClientesService } from './clientes.service';
import { CreateClienteDto, UpdateClienteDto, FindClienteDto } from './dto/create-cliente.dto';
import { AuthGuard } from '@nestjs/passport';

@UseGuards(AuthGuard('jwt'))
@Controller('clientes')
export class ClientesController {
    constructor(private readonly clientesService: ClientesService) { }

    @Get()
    async findAll(@Request() req, @Query() query: FindClienteDto) {
        return this.clientesService.findAll(req.user.empresaId, query);
    }

    @Post()
    async create(@Request() req, @Body() dto: CreateClienteDto) {
        return this.clientesService.create(req.user.empresaId, dto);
    }

    @Put(':id')
    async update(@Param('id') id: string, @Body() dto: UpdateClienteDto) {
        return this.clientesService.update(id, dto);
    }

    @Post(':id/foto')
    @UseInterceptors(FileInterceptor('file'))
    async uploadFoto(@Param('id') id: string, @UploadedFile() file: any) {
        return this.clientesService.uploadFoto(id, file);
    }
}
