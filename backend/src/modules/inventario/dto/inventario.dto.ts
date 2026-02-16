import { IsNotEmpty, IsNumber, IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateEntradaDto {
    @IsUUID()
    sucursalId: string;

    @IsUUID()
    productoId: string;

    @IsNumber()
    cantidad: number;

    @IsOptional()
    @IsString()
    notas?: string;
}

export class CreateProductoDto {
    @IsString()
    nombre: string;
    @IsString()
    categoria: string;
    @IsNumber()
    precio: number;
    @IsNumber()
    costo: number;
}
