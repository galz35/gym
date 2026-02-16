import { IsNotEmpty, IsObject, IsString, IsUUID, IsNumber, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class SyncEventDto {
    @IsNotEmpty()
    @IsString()
    idLocal: string;

    @IsNotEmpty()
    @IsString()
    tipo: string; // CLIENTE, VENTA, etc.

    @IsNotEmpty()
    @IsString()
    accion: string; // CREAR, ACTUALIZAR, ANULAR

    @IsObject()
    payload: any;

    @IsNotEmpty()
    @IsString()
    eventId: string; // Para idempotencia individual (Extras)
}

export class PushSyncDto {
    @IsNotEmpty()
    @IsString()
    deviceId: string;

    @IsNotEmpty()
    @IsUUID()
    requestId: string;

    @IsArray()
    @ValidateNested({ each: true })
    @Type(() => SyncEventDto)
    eventos: SyncEventDto[];
}
