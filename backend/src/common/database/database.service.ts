import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import postgres from 'postgres';

@Injectable()
export class DatabaseService implements OnModuleInit, OnModuleDestroy {
  public sql: postgres.Sql;

  constructor() {
    const dbUrl = process.env.DATABASE_URL!;
    // Append search_path to connection string if not already set
    const separator = dbUrl.includes('?') ? '&' : '?';
    const urlWithSchema = `${dbUrl}${separator}options=-c%20search_path%3Dgym,public`;

    this.sql = postgres(urlWithSchema, {
      max: 20,
      idle_timeout: 30,
      connect_timeout: 5,
      onnotice: () => {},
      transform: { undefined: null },
    });
  }

  async onModuleInit() {
    // Optional init hook
  }

  async onModuleDestroy() {
    await this.sql.end();
  }
}
