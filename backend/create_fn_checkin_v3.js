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
    v_membresia_id UUID := NULL;
    v_fin DATE := NULL;
    v_estado VARCHAR := NULL;
    v_visitas_restantes INT := NULL;
    v_resultado VARCHAR := 'DENEGADO';
    v_motivo VARCHAR := 'SIN_MEMBRESIA';
    v_mensaje TEXT := 'No posee membresía activa o se encuentra vencida.';
    v_error TEXT := NULL;
    v_json_res JSON;
BEGIN
    -- Intentar encontrar membresía activa
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

    IF v_membresia_id IS NOT NULL THEN
        -- Membresía válida
        IF v_visitas_restantes IS NOT NULL AND v_visitas_restantes <= 0 THEN
            v_resultado := 'DENEGADO';
            v_motivo := 'SIN_VISITAS';
            v_mensaje := 'No le quedan visitas disponibles.';
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
    END IF;

    -- Registrar asistencia
    INSERT INTO gym.asistencia (
        empresa_id, sucursal_id, cliente_id, usuario_id, 
        resultado, nota, fecha_hora
    ) VALUES (
        p_empresa_id, p_sucursal_id, p_cliente_id, p_usuario_id,
        v_resultado, COALESCE(p_notas, v_mensaje), NOW()
    );

    IF v_resultado = 'DENEGADO' THEN
        v_error := v_mensaje;
    END IF;

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
    console.log('Function fn_checkin_express updated successfully V3');
    process.exit(0);
}).catch(e => {
    console.error('Error creating function:', e);
    process.exit(1);
});
