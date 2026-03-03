import { Injectable, BadRequestException, NotFoundException, ConflictException } from '@nestjs/common';
import { DatabaseService } from '../../common/database/database.service';
import * as bcrypt from 'bcrypt';
import { CreateUsuarioDto } from './dto/create-usuario.dto';
import { UpdateUsuarioDto } from './dto/update-usuario.dto';

@Injectable()
export class UsuariosService {
    constructor(private db: DatabaseService) { }

    async findAll(empresaId: string) {
        return this.db.sql`
            SELECT u.*, 
                (SELECT json_agg(json_build_object('rol', json_build_object('nombre', r.nombre))) 
                 FROM gym.usuario_rol ur JOIN gym.rol r ON ur.rol_id = r.id WHERE ur.usuario_id = u.id) as roles,
                (SELECT json_agg(json_build_object('sucursal', row_to_json(s))) 
                 FROM gym.usuario_sucursal us JOIN gym.sucursal s ON us.sucursal_id = s.id WHERE us.usuario_id = u.id) as sucursales
            FROM gym.usuario u
            WHERE u.empresa_id = ${empresaId}
        `;
    }

    async findOne(id: string) {
        const [user] = await this.db.sql`
            SELECT u.*, 
                (SELECT json_agg(json_build_object('rol', json_build_object('nombre', r.nombre))) 
                 FROM gym.usuario_rol ur JOIN gym.rol r ON ur.rol_id = r.id WHERE ur.usuario_id = u.id) as roles,
                (SELECT json_agg(json_build_object('sucursal', row_to_json(s))) 
                 FROM gym.usuario_sucursal us JOIN gym.sucursal s ON us.sucursal_id = s.id WHERE us.usuario_id = u.id) as sucursales
            FROM gym.usuario u
            WHERE u.id = ${id}
        `;
        if (!user) throw new NotFoundException('Usuario no encontrado');
        return user;
    }

    async create(createDto: CreateUsuarioDto) {
        const [existing] = await this.db.sql`
            SELECT id FROM gym.usuario 
            WHERE empresa_id = ${createDto.empresaId} AND email = ${createDto.email}
        `;
        if (existing) throw new ConflictException('Email ya registrado en esta empresa');

        const hash = await bcrypt.hash(createDto.password, 10);

        return await this.db.sql.begin(async (sql: any) => {
            const [user] = await sql`
                INSERT INTO gym.usuario (empresa_id, email, nombre, hash, estado, token_version)
                VALUES (${createDto.empresaId}, ${createDto.email}, ${createDto.nombre}, ${hash}, 'ACTIVO', 1)
                RETURNING *
            `;

            if (createDto.roles && createDto.roles.length > 0) {
                const rolesData = createDto.roles.map(rolId => ({ usuario_id: user.id, rol_id: rolId }));
                await sql`INSERT INTO gym.usuario_rol ${sql(rolesData)}`;
            }

            if (createDto.sucursales && createDto.sucursales.length > 0) {
                const sucursalesData = createDto.sucursales.map(sucId => ({ usuario_id: user.id, sucursal_id: sucId }));
                await sql`INSERT INTO gym.usuario_sucursal ${sql(sucursalesData)}`;
            }

            return user;
        });
    }

    async update(id: string, updateDto: UpdateUsuarioDto) {
        const data: any = { ...updateDto };
        if (updateDto.password) {
            data.hash = await bcrypt.hash(updateDto.password, 10);
            delete data.password;
        }

        const [user] = await this.db.sql`
            UPDATE gym.usuario SET ${this.db.sql(data)} WHERE id = ${id} RETURNING *
        `;
        return user;
    }

    async updateRoles(id: string, roleIds: number[]) {
        return await this.db.sql.begin(async (sql: any) => {
            await sql`DELETE FROM gym.usuario_rol WHERE usuario_id = ${id}`;
            if (roleIds.length > 0) {
                const rolesData = roleIds.map(rolId => ({ usuario_id: id, rol_id: rolId }));
                await sql`INSERT INTO gym.usuario_rol ${sql(rolesData)}`;
            }
        });
    }

    async updateSucursales(id: string, sucursalIds: string[]) {
        return await this.db.sql.begin(async (sql: any) => {
            await sql`DELETE FROM gym.usuario_sucursal WHERE usuario_id = ${id}`;
            if (sucursalIds.length > 0) {
                const sucursalesData = sucursalIds.map(sucId => ({ usuario_id: id, sucursal_id: sucId }));
                await sql`INSERT INTO gym.usuario_sucursal ${sql(sucursalesData)}`;
            }
        });
    }

    async setStatus(id: string, active: boolean) {
        const estado = active ? 'ACTIVO' : 'INACTIVO';

        return await this.db.sql.begin(async (sql: any) => {
            if (!active) {
                await sql`
                    UPDATE gym.refresh_token SET revocado_at = NOW() 
                    WHERE usuario_id = ${id} AND revocado_at IS NULL
                `;
                const [user] = await sql`
                    UPDATE gym.usuario SET estado = ${estado}, token_version = token_version + 1 
                    WHERE id = ${id} RETURNING *
                `;
                return user;
            } else {
                const [user] = await sql`
                    UPDATE gym.usuario SET estado = ${estado} WHERE id = ${id} RETURNING *
                `;
                return user;
            }
        });
    }
}
