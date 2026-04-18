const postgres = require('postgres');
const sql = postgres('postgresql://alacaja:TuClaveFuerte@190.56.16.85:5432/gym_db');

const query = `
CREATE OR REPLACE FUNCTION gym.fn_checkin_express(
    p_empresa_id UUID,
    p_sucursal_id UUID,
    p_cliente_id UUID,
    p_usuario_id UUID,
    p_notas TEXT DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
    v_membresia_id UUID;
    v_fin DATE;
    v_estado VARCHAR;
    v_visitas_restantes INT;
    v_resultado VARCHAR;
    v_motivo VARCHAR;
    v_mensaje TEXT;
    v_error TEXT;
    v_json_res JSON;
BEGIN
    -- 1. Intentar encontrar membresía activa (prioridad por fecha fin más lejana)
    SELECT id, fin, estado, visitas_restantes
    INTO v_membresia_id, v_fin, v_estado, v_visitas_restantes
    FROM gym.membresia_cliente
    WHERE empresa_id = p_empresa_id 
      AND cliente_id = p_cliente_id
      AND sucursal_id = p_sucursal_id
      AND estado = 'ACTIVA'
      AND fin >= CURRENT_DATE
    ORDER BY fin DESC
    LIMIT 1;

    -- 2. Evaluar acceso
    IF v_membresia_id IS NOT NULL THEN
        -- Membresía válida
        IF v_visitas_restantes IS NOT NULL AND v_visitas_restantes <= 0 THEN
            v_resultado := 'DENEGADO';
            v_motivo := 'SIN_VISITAS';
            v_mensaje := 'No le quedan visitas disponibles.';
            v_error := v_mensaje;
        ELSE
            v_resultado := 'PERMITIDO';
            v_motivo := 'MEMBRESIA_OK';
            v_mensaje := 'Ingreso permitido. Vence el ' || v_fin;

            -- Descontar visita si aplica
            IF v_visitas_restantes > 0 THEN
                UPDATE gym.membresia_cliente 
                SET visitas_restantes = visitas_restantes - 1,
                    actualizado_at = NOW()
                WHERE id = v_membresia_id;
            END IF;
        END IF;
    ELSE
        -- No hay membresía activa o vigente
        v_resultado := 'DENEGADO';
        v_motivo := 'SIN_MEMBRESIA';
        v_mensaje := 'No posee membresía activa o se encuentra vencida.';
        v_error := v_mensaje;
    END IF;

    -- 3. Registrar en bitacora de asistencias
    INSERT INTO gym.asistencia (
        empresa_id, sucursal_id, cliente_id, usuario_id, 
        resultado, nota, fecha_hora
    ) VALUES (
        p_empresa_id, p_sucursal_id, p_cliente_id, p_usuario_id,
        v_resultado, COALESCE(v_mensaje, p_notas), NOW()
    );

    -- 4. Construir respuesta JSON compatible con AsistenciaService
    v_json_res := json_build_object(
        'acceso', (v_resultado = 'PERMITIDO'),
        'resultado', v_resultado,
        'motivo', v_motivo,
        'mensaje', v_mensaje,
        'error', v_error,
        'membresia_id', v_membresia_id,
        'fin', v_fin
    );

    RETURN v_json_res;
END;
$$ LANGUAGE plpgsql;
`;

sql.unsafe(query).then(() => {
    console.log('Function fn_checkin_express updated successfully');
    process.exit(0);
}).catch(e => {
    console.error('Error creating function:', e);
    process.exit(1);
});
