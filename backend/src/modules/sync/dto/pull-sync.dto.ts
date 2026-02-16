import { IsNumber, IsOptional, IsUUID, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class PullSyncDto {
    @IsNumber()
    @Min(0)
    @Type(() => Number)
    desdeSeq: number;

    @IsOptional()
    @IsUUID()
    sucursalId?: string;

    // Opcional: filtro de entidades específicas?
}
