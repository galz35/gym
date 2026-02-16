import { Module } from '@nestjs/common';
import { VentasService } from './ventas.service';

@Module({
    providers: [VentasService],
    exports: [VentasService],
})
export class VentasModule { }
