import { IsNotEmpty, IsObject, IsOptional, IsString } from 'class-validator';

export class CreateSucursalDto {
    @IsNotEmpty()
    @IsString()
    nombre: string;

    @IsNotEmpty()
    @IsString()
    empresaId: string;

    @IsOptional()
    @IsString()
    direccion?: string;

    @IsOptional()
    @IsObject()
    configJson?: any;
}

export class UpdateSucursalDto {
    @IsOptional()
    @IsString()
    nombre?: string;

    @IsOptional()
    @IsString()
    direccion?: string;

    @IsOptional()
    @IsString()
    estado?: string;

    @IsOptional()
    @IsObject()
    configJson?: any;
}
