# Estado de Integración de API - GymPro

**Fecha de reporte:** 16 de Febrero, 2026
**Estatus:** Pendiente de revisión CRUD

## 🔴 Problema Identificado
Se ha detectado que las operaciones de modificación de datos (**CRUD**) no están funcionando correctamente desde la aplicación Flutter hacia el backend.

### Observaciones:
- **Lectura (GET):** ✅ Funcionando correctamente. La aplicación puede obtener y mostrar datos de sucursales, clientes y dashboard.
- **Escritura (POST/PUT/DELETE):** ❌ Fallando en todas las pantallas. Intentar crear o modificar registros (ej. crear cliente, registrar venta, renovar membresía) devuelve error.

## 🔍 Posibles Causas a Investigar
1. **Validación de `empresaId` en el Backend:** Muchos DTOS de NestJS requieren el `empresaId` de forma explícita en el cuerpo (body) de la petición. Es posible que el frontend no lo esté enviando o lo esté enviando bajo una clave diferente.
2. **Estructura de JSON:** Verificar si los DTOS del backend esperan tipos de datos específicos (ej: UUID vs String plano) que el frontend podría estar enviando mal formateados.
3. **CORS o Seguridad:** Validar si hay algún bloqueo de red específico para métodos que no sean GET en Render/Producción.
4. **Timeouts en Operaciones de Escritura:** Las operaciones que modifican base de datos pueden tomar más tiempo y superar el timeout actual de 15 segundos si el servidor está sobrecargado.

## 📋 Lista de Tareas para la Próxima Sesión
- [ ] Revisar el archivo `lib/core/services/api_service.dart` y asegurar que el `empresaId` se incluya globalmente en las peticiones que lo requieran.
- [ ] Tomar una pantalla específica (ej. Clientes) y depurar el JSON exacto que se está enviando.
- [ ] Comparar contra los DTOS de NestJS en `backend/src/modules/*/dto/*.dto.ts`.
- [ ] Aumentar el tiempo de espera (`receiveTimeout`) en `AppConfig`.

---
*Nota: Este documento sirve como guía para retomar el trabajo y no perder el progreso del diagnóstico actual.*
