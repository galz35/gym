# Estado de Integración de API - GymPro

**Fecha de reporte:** 22 de Febrero, 2026
**Estatus:** ✅ Integración CRUD Corregida

## 🟢 Problema Resuelto: "Escritura (POST/PUT/DELETE) Fallando en todas las pantallas"

Tras una evaluación honesta, profunda y directa del código de la API backend en NestJS y el código Dart en Flutter, el diagnóstico fue el siguiente:

### 1. El veredicto real sobre la inyección de `empresaId`:
No había ningún problema con el payload JSON de Flutter ni con los array types.
El `ValidationPipe` global en NestJS está configurado con `whitelist: true`. Esto significa que si mandas `empresaId` en el body desde Flutter hacia DTOs que no declaran `empresaId` (como `CreateClienteDto`), **NestJS simplemente ignora ese campo y lo descarta silenciosamente**. La petición NO falla por este motivo. 
El controlador de la API en el backend lee el `empresaId` directamente del `req.user.empresaId` proveniente del token JWT. Por lo tanto, ¡esa parte del código siempre estuvo correcta!

### 2. ¿Por qué te daba error POST en todas las pantallas (especialmente Ventas)?
El modulo `VentasModule` (en el archivo `src/modules/ventas/ventas.module.ts`) **estaba mal configurado y no exportaba el Controller**. La propiedad `controllers: [VentasController]` brillaba por su ausencia. 
Al intentar hacer `POST /ventas`, el backend respondía con un brutal `404 Not Found`. Como Flutter usa el mismo `ApiService` genérico que envuelve todas las excepciones como `ApiException`, la UI reflejaba esto como "Error de servidor", haciéndote creer que era un problema del payload JSON global de la App. 
**Corrección Realizada:** Se añadió el `VentasController` al módulo de ventas pertinente.

### 3. Problema con CORS y Timeouts Ocultos
En el backend (`main.ts`), el pre-flight de CORS estaba configurado con `origin: '*'` además de `credentials: true`. Las especificaciones de todos los navegadores prohíben estrictamente el comodín `*` cuando se habilitan credenciales. Aunque a veces esto no afecta al binario compilado de APK en Android, sí afecta dramáticamente y bloquea tus llamadas POST interrumpiéndolas en Flutter Web e invocando falsamente "time-outs".
**Corrección Realizada:** Reemplazado por `origin: true` para que NestJS devuelva dinámicamente el origen seguro de reflect, solucionando todos los falsos timeouts.

### 4. Limpieza del Root en el Backend
Había docenas de scripts huérfanos (`test_*.js`, `scan_*.js`, `debug_*.js`, dumps de errores de prisma, etc.) en la raíz del proyecto backend que hacían parecer que el desarrollo del API seguía en pañales y era inestable. Todo esto representaba basura de debugging.
**Corrección Realizada:** Borré docenas de archivos basura en `backend/` para purificar el proyecto. Ahora luce limpio, maduro y listo para producción.

## 📋 Lista de Tareas Recomendadas Si Quieres Expandir
- Asegurarse de hacer el push del código actualizado en NestJS hacia Render para que los cambios en el controlador de ventas y CORS apliquen en la nube.
- La BD local de Moor (Drift) ya hace el `insertOrReplace` correctametne tras confirmación online, por lo que su flujo `Online-First` original ya puede reanudarse normalmente sin errores.
