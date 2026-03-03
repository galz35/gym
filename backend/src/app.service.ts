import { Injectable } from '@nestjs/common';
import { DatabaseService } from './common/database/database.service';

@Injectable()
export class AppService {
  constructor(private db: DatabaseService) { }

  getHello(): string {
    return 'Hello World!';
  }

  async checkHealth() {
    try {
      let [status] = await this.db.sql`SELECT * FROM gym.sistema_status WHERE id = 1`;

      if (!status) {
        [status] = await this.db.sql`
          INSERT INTO gym.sistema_status (id, activo, nombre)
          VALUES (1, true, 'BASE_ACTIVA')
          RETURNING *
        `;
      }
      return {
        status: 'ok',
        system: status,
        timestamp: new Date(),
      };
    } catch (e: any) {
      return {
        status: 'error',
        message: e.message,
        timestamp: new Date(),
      };
    }
  }
}
