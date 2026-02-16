import { Module } from '@nestjs/common';
import { AsistenciaService } from './asistencia.service';
import { AsistenciaController } from './asistencia.controller';

@Module({
    providers: [AsistenciaService],
    controllers: [AsistenciaController],
    exports: [AsistenciaService],
})
export class AsistenciaModule { }
