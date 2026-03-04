import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import postgres from 'postgres';

@Injectable()
export class DatabaseService implements OnModuleInit, OnModuleDestroy {
  public sql: postgres.Sql;

  constructor() {
    this.sql = postgres(process.env.DATABASE_URL!, {
      max: 20,
      idle_timeout: 30,
      connect_timeout: 5,
    });
  }

  async onModuleInit() {
    // Optional init hook
  }

  async onModuleDestroy() {
    await this.sql.end();
  }
}
