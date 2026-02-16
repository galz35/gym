import { Module, Global } from '@nestjs/common';
import { PrismaService } from './prisma/prisma.service';
import { HealthController } from './health/health.controller';
import { SupabaseService } from './supabase/supabase.service';

@Global()
@Module({
    providers: [PrismaService, SupabaseService],
    controllers: [HealthController],
    exports: [PrismaService, SupabaseService],
})
export class CommonModule { }
