# Revision Tecnica 2026-04-18

## Implementado en esta intervencion

- Recarga reactiva de pantallas Flutter cuando termina la hidratacion de sesion o cambia la sucursal activa.
- Correcciones de contrato entre Flutter y backend en usuarios.
- Historial de turnos de caja con endpoint backend y vista Flutter.
- Notificaciones con marcado local de lectura y ordenamiento funcional de planes.
- Correccion de errores de integracion detectados por inspeccion estatica.

## No tocado por seguridad o por falta de contexto operativo

- Validacion TLS globalmente deshabilitada:
  - `flutter/lib/main.dart`
  - `backend/src/main.ts`
  Razón: quitarlo sin validar certificados, proxies y servicios externos podria romper login, storage o integraciones HTTPS del entorno actual.

- Verificacion automatica del proyecto Flutter:
  Razón: en este VPS no estan instalados `flutter` ni `dart`, por lo que no fue posible ejecutar `flutter analyze`, `dart format` ni builds moviles reales.

- Persistencia real de notificaciones leidas:
  La UX local ya responde, pero no existe en este repo una entidad/endpoint dedicado para almacenar estado de lectura por usuario.

## Riesgos remanentes a validar en ambiente

- Probar cambio de sucursal y confirmar que dashboard, membresias, reportes, caja, POS e inventario refrescan datos correctamente.
- Probar creacion de usuario y verificar que la sucursal actual se asigne segun lo esperado.
- Validar historial de caja con datos reales del usuario autenticado.
- Ejecutar `flutter analyze` y una corrida real en dispositivo o emulador cuando el SDK este disponible.
