import postgres from 'postgres';
import * as dotenv from 'dotenv';
dotenv.config();

const sql = postgres(process.env.DATABASE_URL!, {
    ssl: { rejectUnauthorized: false }
});

async function main() {
    console.log('--- Optimizando Base de Datos para Máxima Velocidad ---');

    try {
        // 1. Extensiones necesarias
        console.log('Activando pg_trgm para búsquedas instantáneas...');
        await sql`CREATE EXTENSION IF NOT EXISTS pg_trgm`;

        // 2. Índice de Trigramas para el nombre del cliente
        console.log('Creando índice de trigramas en cliente.nombre...');
        await sql`CREATE INDEX IF NOT EXISTS idx_cliente_nombre_trgm ON gym.cliente USING gin (nombre gin_trgm_ops)`;

        // 3. Stored Procedure: fn_checkin_express
        console.log('Creando Procedimiento Almacenado fn_checkin_express...');
        await sql`
      CREATE OR REPLACE FUNCTION gym.fn_checkin_express(
        p_empresa_id UUID,
        p_sucursal_id UUID,
        p_cliente_id UUID,
        p_usuario_id UUID,
        p_notas TEXT DEFAULT NULL
      ) RETURNS JSON AS $$
      DECLARE
        v_cliente_estado VARCHAR(20);
        v_cliente_nombre VARCHAR(250);
        v_cliente_foto_url VARCHAR(500);
        v_membresia_id UUID;
        v_membresia_fin DATE;
        v_membresia_sucursal_id UUID;
        v_visitas_restantes INT;
        v_plan_tipo VARCHAR(20);
        v_plan_multisede BOOLEAN;
        v_plan_nombre VARCHAR(150);
        v_resultado VARCHAR(20) := 'DENEGADO';
        v_motivo VARCHAR(50) := 'SIN_MEMBRESIA';
        v_asistencia_id UUID;
      BEGIN
        -- 1. Obtener datos del cliente y su membresía más vigente de un solo golpe
        SELECT 
          c.estado, c.nombre, c.foto_url,
          m.id, m.fin, m.sucursal_id, m.visitas_restantes,
          p.tipo, p.multisede, p.nombre
        INTO 
          v_cliente_estado, v_cliente_nombre, v_cliente_foto_url,
          v_membresia_id, v_membresia_fin, v_membresia_sucursal_id, v_visitas_restantes,
          v_plan_tipo, v_plan_multisede, v_plan_nombre
        FROM gym.cliente c
        LEFT JOIN gym.membresia_cliente m ON c.id = m.cliente_id 
          AND m.estado = 'ACTIVA' 
          AND m.fin >= CURRENT_DATE
        LEFT JOIN gym.plan_membresia p ON m.plan_id = p.id
        WHERE c.id = p_cliente_id
        ORDER BY m.fin DESC
        LIMIT 1;

        -- 2. Validaciones básicas
        IF v_cliente_estado IS NULL THEN
          RETURN json_build_object('error', 'Cliente no encontrado');
        END IF;

        IF v_cliente_estado != 'ACTIVO' THEN
          RETURN json_build_object('error', 'Cliente inactivo');
        END IF;

        -- 3. Lógica de Membresía
        IF v_membresia_id IS NOT NULL THEN
          -- Validar Sucursal
          IF v_membresia_sucursal_id = p_sucursal_id OR v_plan_multisede = TRUE THEN
            v_resultado := 'PERMITIDO';
            v_motivo := 'OK';
          ELSE
            v_resultado := 'DENEGADO';
            v_motivo := 'SUCURSAL_INCORRECTA';
          END IF;

          -- Validar Visitas si aplica
          IF v_resultado = 'PERMITIDO' AND v_plan_tipo = 'VISITAS' THEN
            IF v_visitas_restantes <= 0 THEN
              v_resultado := 'DENEGADO';
              v_motivo := 'SIN_VISITAS';
            END IF;
          END IF;
        END IF;

        -- 4. Registrar Asistencia (Tarea crítica)
        INSERT INTO gym.asistencia (
          empresa_id, sucursal_id, cliente_id, usuario_id, fecha_hora, resultado, nota
        ) VALUES (
          p_empresa_id, p_sucursal_id, p_cliente_id, p_usuario_id, NOW(), v_resultado, COALESCE(p_notas, v_motivo)
        ) RETURNING id INTO v_asistencia_id;

        -- 5. Descontar visitas si fue exitoso y es de tipo visitas
        IF v_resultado = 'PERMITIDO' AND v_plan_tipo = 'VISITAS' THEN
          UPDATE gym.membresia_cliente 
          SET visitas_restantes = visitas_restantes - 1 
          WHERE id = v_membresia_id AND visitas_restantes > 0;
          
          -- Si no se pudo actualizar (concurrencia), revertimos a denegado
          IF NOT FOUND THEN
             UPDATE gym.asistencia SET resultado = 'DENEGADO', nota = 'SIN_VISITAS_CONCURRENTE' WHERE id = v_asistencia_id;
             v_resultado := 'DENEGADO';
             v_motivo := 'SIN_VISITAS';
          END IF;
        END IF;

        -- 6. Retornar resultado
        RETURN json_build_object(
          'acceso', (v_resultado = 'PERMITIDO'),
          'motivo', v_motivo,
          'mensaje', CASE WHEN v_resultado = 'PERMITIDO' THEN 'Acceso concedido' ELSE 'Acceso denegado: ' || v_motivo END,
          'asistenciaId', v_asistencia_id,
          'cliente', json_build_object('nombre', v_cliente_nombre, 'foto', v_cliente_foto_url),
          'membresia', CASE WHEN v_membresia_id IS NOT NULL THEN json_build_object('plan', v_plan_nombre, 'fin', v_membresia_fin) ELSE NULL END
        );
      END;
      $$ LANGUAGE plpgsql;
    `;

        console.log('¡Éxito! Base de Datos optimizada al 100%.');
    } catch (err) {
        console.error('Error optimizando:', err);
    } finally {
        await sql.end();
    }
}

main();
