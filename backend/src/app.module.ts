import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CommonModule } from './common/common.module';
import { AuthModule } from './modules/auth/auth.module';
import { SucursalesModule } from './modules/sucursales/sucursales.module';
import { UsuariosModule } from './modules/usuarios/usuarios.module';
import { VentasModule } from './modules/ventas/ventas.module';
import { SyncModule } from './modules/sync/sync.module';
import { PlanesModule } from './modules/planes/planes.module';
import { InventarioModule } from './modules/inventario/inventario.module';
import { ReportesModule } from './modules/reportes/reportes.module';
import { ClientesModule } from './modules/clientes/clientes.module';
import { AsistenciaModule } from './modules/asistencia/asistencia.module';
import { TrasladosModule } from './modules/traslados/traslados.module';
import { CajaModule } from './modules/caja/caja.module';
import { MembresiasModule } from './modules/membresias/membresias.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    CommonModule,
    AuthModule,
    SucursalesModule,
    UsuariosModule,
    VentasModule,
    SyncModule,
    PlanesModule,
    InventarioModule,
    ReportesModule,
    ClientesModule,
    AsistenciaModule,
    TrasladosModule,
    CajaModule,
    MembresiasModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
