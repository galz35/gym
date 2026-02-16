import { IsNotEmpty, IsNumber, IsOptional, IsString, IsUUID } from 'class-validator';

export class OpenCajaDto {
    @IsUUID()
    sucursalId: string;

    @IsNumber()
    montoApertura: number;
}

export class CloseCajaDto {
    @IsNumber()
    montoCierre: number;

    @IsOptional()
    @IsString()
    notaCierre?: string;
}
