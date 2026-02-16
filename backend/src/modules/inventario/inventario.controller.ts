import { Controller, Get, Post, Body, Param, UseGuards, Request } from '@nestjs/common';
import { InventarioService } from './inventario.service';
import { CreateEntradaDto, CreateProductoDto } from './dto/inventario.dto';
import { AuthGuard } from '@nestjs/passport';

@UseGuards(AuthGuard('jwt'))
@Controller('inventario')
export class InventarioController {
    constructor(private readonly inventarioService: InventarioService) { }

    @Get('productos')
    async findAllProductos(@Request() req) {
        return this.inventarioService.findAllProductos(req.user.empresaId);
    }

    @Get('stock/:sucursalId')
    async findStock(@Param('sucursalId') sucursalId: string) {
        return this.inventarioService.findStockSucursal(sucursalId);
    }

    @Get('top/:sucursalId')
    async getTopProductos(@Request() req, @Param('sucursalId') sucursalId: string) {
        return this.inventarioService.getTopProductos(req.user.empresaId, sucursalId);
    }

    @Post('productos')
    async createProducto(@Request() req, @Body() dto: CreateProductoDto) {
        return this.inventarioService.createProducto(req.user.empresaId, dto);
    }

    @Post('entrada')
    async registrarEntrada(@Request() req, @Body() dto: CreateEntradaDto) {
        return this.inventarioService.registrarEntrada(req.user.empresaId, req.user.userId, dto);
    }
}
