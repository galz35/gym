import { Controller, Get, Post, Put, Body, Param, UseGuards, Request, ForbiddenException } from '@nestjs/common';
import { UsuariosService } from './usuarios.service';
import { CreateUsuarioDto } from './dto/create-usuario.dto';
import { UpdateUsuarioDto } from './dto/update-usuario.dto';
import { AuthGuard } from '@nestjs/passport';

@UseGuards(AuthGuard('jwt'))
@Controller('usuarios')
export class UsuariosController {
    constructor(private readonly usuariosService: UsuariosService) { }

    @Get()
    async findAll(@Request() req) {
        // Only admin? For now let any authenticated user see in same company? Or check roles.
        // MVP: Check roles if needed, or just filter by company.
        return this.usuariosService.findAll(req.user.empresaId);
    }

    @Post()
    async create(@Request() req, @Body() createDto: CreateUsuarioDto) {
        if (createDto.empresaId !== req.user.empresaId) {
            throw new ForbiddenException('No puedes crear usuarios para otra empresa');
        }
        return this.usuariosService.create(createDto);
    }

    @Put(':id')
    async update(@Param('id') id: string, @Body() updateDto: UpdateUsuarioDto) {
        return this.usuariosService.update(id, updateDto);
    }

    @Put(':id/roles')
    async updateRoles(@Param('id') id: string, @Body('roles') roles: number[]) {
        return this.usuariosService.updateRoles(id, roles);
    }

    @Put(':id/sucursales')
    async updateSucursales(@Param('id') id: string, @Body('sucursales') sucursales: string[]) {
        return this.usuariosService.updateSucursales(id, sucursales);
    }

    @Post(':id/activar')
    async activate(@Param('id') id: string) {
        return this.usuariosService.setStatus(id, true);
    }

    @Post(':id/inactivar')
    async deactivate(@Param('id') id: string) {
        return this.usuariosService.setStatus(id, false);
    }
}
