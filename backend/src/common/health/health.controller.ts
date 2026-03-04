import { Controller, Get, ServiceUnavailableException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';

@Controller('health')
export class HealthController {
  constructor(private db: DatabaseService) {}

  @Get('ping')
  async ping() {
    try {
      // Test DB connection and keep-alive
      let [status] = await this.db
        .sql`SELECT * FROM gym.sistema_status LIMIT 1`;

      if (!status) {
        [status] = await this.db.sql`
                    INSERT INTO gym.sistema_status (id, nombre, activo)
                    VALUES (1, 'BASE_ACTIVA', true)
                    RETURNING *
                `;
      } else {
        await this.db.sql`
                    UPDATE gym.sistema_status
                    SET timestamp = NOW()
                    WHERE id = ${status.id}
                `;
      }

      return {
        status: 'ok',
        system: status.nombre,
        database: 'connected',
        timestamp: new Date().toISOString(),
      };
    } catch (error: any) {
      throw new ServiceUnavailableException({
        status: 'error',
        database: 'disconnected',
        error: error.message,
      });
    }
  }
}
