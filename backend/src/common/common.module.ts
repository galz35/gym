import { Module, Global } from '@nestjs/common';

import { DatabaseService } from './database/database.service';
import { HealthController } from './health/health.controller';
import { SupabaseService } from './supabase/supabase.service';

@Global()
@Module({
    providers: [DatabaseService, SupabaseService],
    controllers: [HealthController],
    exports: [DatabaseService, SupabaseService],
})
export class CommonModule { }
