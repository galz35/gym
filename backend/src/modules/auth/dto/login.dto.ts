import { IsEmail, IsNotEmpty, IsString, IsUUID, IsOptional } from 'class-validator';

export class LoginDto {
    @IsEmail()
    email: string;

    @IsNotEmpty()
    @IsString()
    password: string;

    @IsOptional()
    @IsUUID()
    empresaId?: string;
}
