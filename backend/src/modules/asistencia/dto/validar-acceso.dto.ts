import { IsNotEmpty, IsUUID, IsOptional, IsString } from 'class-validator';

export class ValidarAccesoDto {
    @IsUUID()
    clienteId: string;

    @IsUUID()
    sucursalId: string;

    @IsOptional()
    @IsString()
    notas?: string;
}
