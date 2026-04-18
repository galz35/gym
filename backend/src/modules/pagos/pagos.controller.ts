import { Body, Controller, Get, Post, Query, Request, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { PagosService } from './pagos.service';
import { CreateGastoDto } from './dto/create-gasto.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('pagos')
export class PagosController {
  constructor(private readonly pagosService: PagosService) {}

  @Get()
  async findByCaja(@Request() req, @Query('cajaId') cajaId: string) {
    return this.pagosService.findByCaja(req.user.empresaId, cajaId);
  }

  @Post('gasto')
  async createGasto(@Request() req, @Body() dto: CreateGastoDto) {
    return this.pagosService.createGasto(req.user.empresaId, req.user.userId, dto);
  }
}
