import { IsInt, IsNotEmpty, IsOptional, IsString, IsUUID, Min } from 'class-validator';

export class CreateGastoDto {
  @IsUUID()
  @IsNotEmpty()
  caja_id: string;

  @IsInt()
  @Min(1)
  monto_centavos: number;

  @IsOptional()
  @IsString()
  descripcion?: string;
}
