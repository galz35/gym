import { IsEmail, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateClienteDto {
    @IsNotEmpty()
    @IsString()
    nombre: string;

    @IsOptional()
    @IsString()
    telefono?: string;

    @IsOptional()
    @IsEmail()
    email?: string;

    @IsOptional()
    @IsString()
    documento?: string;
}

export class UpdateClienteDto {
    @IsOptional()
    @IsString()
    nombre?: string;
    @IsOptional()
    telefono?: string;
    @IsOptional()
    email?: string;
    @IsOptional()
    documento?: string;
    @IsOptional()
    estado?: string;
}

export class FindClienteDto {
    @IsOptional()
    @IsString()
    buscar?: string;
    @IsOptional()
    limit?: string;
}
