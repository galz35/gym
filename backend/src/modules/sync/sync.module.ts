import { Module } from '@nestjs/common';
import { SyncService } from './sync.service';
import { SyncController } from './sync.controller';
import { VentasModule } from '../ventas/ventas.module';
// @ts-ignore
import { CajaModule } from '../caja/caja.module';
// @ts-ignore
import { InventarioModule } from '../inventario/inventario.module';

@Module({
    imports: [VentasModule, CajaModule, InventarioModule],
    controllers: [SyncController],
    providers: [SyncService],
})
export class SyncModule { }
