# Revision Tecnica 2026-04-18

## Implementado en esta intervencion

- Recarga reactiva de pantallas Flutter cuando termina la hidratacion de sesion o cambia la sucursal activa.
- Correcciones de contrato entre Flutter y backend en usuarios.
- Historial de turnos de caja con endpoint backend y vista Flutter.
- Notificaciones con marcado local de lectura y ordenamiento funcional de planes.
- Correccion de errores de integracion detectados por inspeccion estatica.
- Refresco correcto del usuario en memoria al renovar token y rehidratacion de sucursal.
- Soporte backend para resumen de reportes por rango y conexion real del selector de rango en Flutter.
- Mejoras de `sync pull` para stock y borrados en tablas soportadas.

## No tocado por seguridad o por falta de contexto operativo

- Validacion TLS globalmente deshabilitada:
  - `flutter/lib/main.dart`
  - `backend/src/main.ts`
  Razón: quitarlo sin validar certificados, proxies y servicios externos podria romper login, storage o integraciones HTTPS del entorno actual.

- Verificacion automatica del proyecto Flutter:
  Razón: en este VPS no estan instalados `flutter` ni `dart`, por lo que no fue posible ejecutar `flutter analyze`, `dart format` ni builds moviles reales.

- Persistencia real de notificaciones leidas:
  La UX local ya responde, pero no existe en este repo una entidad/endpoint dedicado para almacenar estado de lectura por usuario.

- Sincronizacion offline completa:
  Existe `OfflineSyncService`, pero no hay escrituras reales a `syncLog` desde los flujos de negocio, asi que `performPush()` no tiene eventos para subir en uso normal. Ademas, el pull solo cubre parcialmente entidades locales.

- Analitica avanzada de reportes:
  El resumen principal ya responde a rango real, pero la pantalla de reportes todavia contiene varios graficos y porcentajes hardcodeados que no tienen backend dedicado en este repo.

## Riesgos remanentes a validar en ambiente

- Probar cambio de sucursal y confirmar que dashboard, membresias, reportes, caja, POS e inventario refrescan datos correctamente.
- Probar creacion de usuario y verificar que la sucursal actual se asigne segun lo esperado.
- Validar historial de caja con datos reales del usuario autenticado.
- Validar que los endpoints autenticados principales respondan con un usuario real; desde este VPS solo se pudo hacer smoke test anonimo a `GET /health/ping`.
- Ejecutar `flutter analyze` y una corrida real en dispositivo o emulador cuando el SDK este disponible.
