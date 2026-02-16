import { IsNotEmpty, IsNumber, IsOptional, IsString, IsInt, IsBoolean, IsUUID } from 'class-validator';

export class CreatePlanDto {
    @IsNotEmpty()
    @IsString()
    nombre: string;

    @IsNotEmpty()
    @IsString()
    tipo: string; // DIAS | VISITAS

    @IsOptional()
    @IsInt()
    dias?: number;

    @IsOptional()
    @IsInt()
    visitas?: number;

    @IsNumber()
    precio: number;

    @IsOptional()
    @IsString()
    descripcion?: string; // "Semanal", "Mensual", "Anual", "Visita Unica"

    @IsOptional()
    @IsBoolean()
    multisede?: boolean;

    @IsOptional()
    @IsUUID()
    sucursalId?: string;
}

export class UpdatePlanDto {
    @IsOptional()
    @IsString()
    nombre?: string;

    @IsOptional()
    @IsString()
    descripcion?: string;

    @IsOptional()
    @IsNumber()
    precio?: number;

    @IsOptional()
    @IsString()
    estado?: string;
}
