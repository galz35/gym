import { Module } from '@nestjs/common';
import { TrasladosService } from './traslados.service';
import { TrasladosController } from './traslados.controller';

@Module({
    providers: [TrasladosService],
    controllers: [TrasladosController],
    exports: [TrasladosService],
})
export class TrasladosModule { }
