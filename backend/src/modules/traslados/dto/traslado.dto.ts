import { IsNotEmpty, IsUUID, IsNumber, IsArray, IsOptional, Min, IsString } from 'class-validator';

export class CreateTrasladoDto {
    @IsUUID()
    sucursalOrigenId: string;

    @IsUUID()
    sucursalDestinoId: string;

    @IsArray()
    detalles: TrasladoDetalleDto[];
}

export class TrasladoDetalleDto {
    @IsUUID()
    productoId: string;

    @IsNumber()
    @Min(0.01)
    cantidad: number;
}
