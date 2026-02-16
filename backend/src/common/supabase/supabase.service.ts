import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService {
    private supabase: SupabaseClient;
    private readonly logger = new Logger(SupabaseService.name);

    constructor(private configService: ConfigService) {
        const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
        const supabaseKey = this.configService.get<string>('SUPABASE_KEY');

        if (supabaseUrl && supabaseKey) {
            this.supabase = createClient(supabaseUrl, supabaseKey);
        } else {
            this.logger.warn('Supabase URL or Key not found in environment variables. Storage disabled.');
        }
    }

    async uploadFile(bucket: string, path: string, fileBuffer: Buffer, mimeType: string): Promise<string> {
        if (!this.supabase) return null;

        const { data, error } = await this.supabase.storage
            .from(bucket)
            .upload(path, fileBuffer, {
                contentType: mimeType,
                upsert: true,
            });

        if (error) {
            this.logger.error(`Error uploading file to ${bucket}/${path}: ${error.message}`);
            throw error;
        }

        const { data: { publicUrl } } = this.supabase.storage
            .from(bucket)
            .getPublicUrl(path);

        return publicUrl;
    }
}
