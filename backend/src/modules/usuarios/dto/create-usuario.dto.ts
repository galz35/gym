import { IsEmail, IsNotEmpty, IsString, IsUUID, IsOptional, MinLength } from 'class-validator';

export class CreateUsuarioDto {
    @IsUUID()
    @IsNotEmpty()
    empresaId: string;

    @IsEmail()
    @IsNotEmpty()
    email: string;

    @IsString()
    @IsNotEmpty()
    nombre: string;

    @IsString()
    @IsNotEmpty()
    @MinLength(6)
    password: string;

    @IsOptional()
    roles?: number[]; // IDs de roles

    @IsOptional()
    sucursales?: string[]; // IDs de sucursales
}
