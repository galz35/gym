import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../common/database/database.service';
import {
  CreateSucursalDto,
  UpdateSucursalDto,
} from './dto/create-sucursal.dto';

@Injectable()
export class SucursalesService {
  constructor(private db: DatabaseService) {}

  async findAll(empresaId: string) {
    return this.db.sql`
            SELECT * FROM gym.sucursal WHERE empresa_id = ${empresaId}
        `;
  }

  async findOne(id: string) {
    const [sucursal] = await this.db.sql`
            SELECT * FROM gym.sucursal WHERE id = ${id}
        `;
    if (!sucursal) throw new NotFoundException('Sucursal no encontrada');
    return sucursal;
  }

  async create(dto: CreateSucursalDto) {
    const [sucursal] = await this.db.sql`
            INSERT INTO gym.sucursal (empresa_id, nombre, direccion, config_json)
            VALUES (${dto.empresaId}, ${dto.nombre}, ${dto.direccion || null}, ${this.db.sql.json(dto.configJson || {})})
            RETURNING *
        `;
    return sucursal;
  }

  async update(id: string, dto: UpdateSucursalDto) {
    const updates: any = { actualizado_at: this.db.sql`NOW()` };
    if (dto.nombre) updates.nombre = dto.nombre;
    if (dto.direccion !== undefined) updates.direccion = dto.direccion;
    if (dto.configJson !== undefined)
      updates.config_json = this.db.sql.json(dto.configJson);

    const [sucursal] = await this.db.sql`
            UPDATE gym.sucursal SET ${this.db.sql(updates)} WHERE id = ${id} RETURNING *
        `;
    return sucursal;
  }

  async setStatus(id: string, active: boolean) {
    const estado = active ? 'ACTIVO' : 'INACTIVO';
    const [sucursal] = await this.db.sql`
            UPDATE gym.sucursal SET estado = ${estado}, actualizado_at = NOW() WHERE id = ${id} RETURNING *
        `;
    return sucursal;
  }
}
