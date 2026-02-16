import { IsEmail, IsNotEmpty, IsOptional, IsString, IsUUID } from 'class-validator';

export class UpdateUsuarioDto {
    @IsOptional()
    @IsEmail()
    email?: string; // No debería cambiarse a menudo

    @IsOptional()
    @IsString()
    nombre?: string;

    @IsOptional()
    @IsString()
    password?: string; // Si se envía, se hashea

    @IsOptional()
    @IsString()
    estado?: string; // ACTIVO/INACTIVO
}
