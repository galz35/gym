# Análisis de Brechas en API (Backend vs Frontend Needs)

He diseñado las pantallas de Flutter para ser "Cero Fricción" y "Premium". Para que funcionen al 100% como se ven, el backend (NestJS + Supabase) necesita cubrir estos puntos adicionales:

## 1. Imágenes de Usuario (WebP)
- **Frontend**: Requiere subir foto de perfil desde cámara/galería, comprimida a WebP (~50kb).
- **Backend Necesario**:
  - Endpoint `POST /clientes/:id/foto` que reciba `multipart/form-data`.
  - Almacenamiento en Supabase Storage (bucket `clientes`).
  - Guardar URL pública en tabla `cliente`.
  
## 2. Precios Específicos por Sucursal
- **Frontend**: Pantalla `PlanesScreen` muestra precios que varían por gym.
- **Backend Actual**: Tabla `plan_membresia` tiene `empresa_id`.
- **Mejora Necesaria**:
  - Opción A: Tabla `plan_sucursal` (plan_id, sucursal_id, precio_ajustado).
  - Opción B (Más simple): Crear planes duplicados por sucursal si varían mucho, o añadir `sucursal_id` nullable a `plan_membresia` (si es null = todas, si no = específica).

## 3. Inventario: Entradas y Ajustes
- **Frontend**: Pantalla `InventarioScreen` permite "Registrar Entrada" (compra) con costo.
- **Backend Actual**: Tabla `movimiento_inventario` existe.
- **Validación**: Asegurar que el endpoint `POST /inventario/entrada` calcule el Costo Promedio Ponderado si se desea, o simplemente registre el último costo.

## 4. Reportes Avanzados para Dueño
- **Frontend**: Gráfico de "Asistencia por Hora" (ej: pico a las 6pm).
- **Backend Necesario**:
  - Endpoint `GET /reportes/asistencia-hora?fecha=YYYY-MM-DD`
  - Query SQL: `SELECT EXTRACT(HOUR FROM fecha_hora) as hora, COUNT(*) FROM asistencia GROUP BY hora`.
  
## 5. Venta Rápida (POS)
- **Frontend**: grid de "Productos Rápidos" (Top vendidos).
- **Backend Necesario**:
  - Endpoint `GET /productos/top` o lógica para ordenar por frecuencia de venta.

## 6. Cambio de Contexto (Admin multi-gym)
- **Frontend**: Selector de sucursal en el Drawer.
- **Backend**: El token JWT ya tiene permisos, pero el backend debe filtrar TODO por `sucursal_id` enviado en el header `x-sucursal-id` (o query param) para que el admin no vea datos mezclados.

**Estado General**: La estructura actual de BD soporta el 90% de esto. Solo faltan los endpoints de reportes agregados y la subida de archivos.
