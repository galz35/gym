# Plan Estratégico de Desarrollo y Lanzamiento: GymPro (Marzo 2026)

Este plan de trabajo está diseñado para ser directo, accionable y enfocado en generar valor inmediato basándonos en la estabilización reciente del Backend (NestJS) y Frontend (Flutter). Se divide en 3 fases críticas: **Consolidación, Innovación (Recepción/Biometría), y Expansión (App Clientes).**

---

## FASE 1: Consolidación y Despliegue a Producción (Corto Plazo - Esta Semana)
*Objetivo: Poner la App Administrativa actual en manos del personal del gimnasio con cero errores en caja y ventas.*

*   **Paso 1.1: Sincronización Push al Servidor (Backend)**
    *   *Acción:* Hacer el commit y push de las correcciones críticas hechas hoy en NestJS (CORS de la API y el arreglo del `VentasModule` que impedía vender) hacia el servidor de producción (Render/Railway/AWS).
    *   *Responsable:* IA/Desarrollador.
    *   *Definición de Hecho:* Postman o el cliente Flutter pueden registrar una venta y cobrar un producto retornando `201 Created` desde el servidor en la nube.
*   **Paso 1.2: Pruebas de Estrés en "Punto de Venta" (Caja y POS)**
    *   *Acción:* Navegar en la app Flutter a la pantalla de POS. Agregar 3 productos, registrar un solo pago mixto (Efectivo/Tarjeta) y cerrar la venta. Luego, hacer el Cierre de Caja y validar que el sobrante o faltante sea exacto.
    *   *Definición de Hecho:* Un ciclo de vida completo de dinero (Apertura -> Ventas -> Cierre) reflejado en los dashboards sin errores.
*   **Paso 1.3: Limpieza y "Release" de APK/Web (Flutter)**
    *   *Acción:* Compilar la app Flutter en versión `release` para Web y generar un APK para Android. Esto asegura que el código minimizado no rompa con la nueva regla de CORS.

---

## FASE 2: La Recepción "Anti-Trampa" (Mediano Plazo - Próximas 2 Semanas)
*Objetivo: Implementar la prevención de pérdida de dinero a través del reconocimiento fotográfico/biométrico en la recepción.*

*   **Paso 2.1: Perfil de Cliente con Foto Obligatoria**
    *   *Acción:* Asegurar que en Flutter, al crear o editar un cliente, la carga de la foto (o tomarla con la cámara del dispositivo) sea un proceso rápido de 2 clics y se guarde en `Supabase Storage`.
*   **Paso 2.2: Pantalla de "Control de Acceso (Check-In)"**
    *   *Acción:* Modificar la pantalla `CheckinScreen`. Cuando un usuario ingresa su documento o escanea un código QR, el sistema debe arrojar una **Tarjeta Gigante** que ocupe media pantalla con la **Foto del Cliente**, su estatus de pago (Verde/Rojo) y si está permitido pasar.
    *   *Definición de Hecho:* El recepcionista ya no lee texto, solo aprueba un rostro verde o rechaza uno rojo.
*   **Paso 2.3: Configuración de Biometría Fácil (Supabase Vectors)**
    *   *Acción:* Validar el endpoint que procesa la biometría fácil apoyándose de las funciones RPC de Supabase que ya están semi-configuradas.

---

## FASE 3: GymPro Client App (Ocupación de Zonas) (Largo Plazo - 1 a 2 Meses)
*Objetivo: Lanzar el producto derivado para los miembros del fitness, brindando una experiencia Premium que reduzca la queja de "gimnasio lleno".*

*   **Paso 3.1: Diseño de la App Cliente (UI/UX)**
    *   *Acción:* Crear un nuevo proyecto Flutter ligero (ej. `gympro_client`).
    *   *Funciones Clave:* "Mi QR" (Para entrar), "Mi Membresía" (Días restantes) y la "Ocupación de Zonas".
*   **Paso 3.2: Endpoint de "Aforo" (NestJS)**
    *   *Acción:* Escribir un endpoint en el backend (`GET /asistencia/aforo`) que cuente cuántos "Check-ins" existen en las últimas 2 horas menos los "Check-outs".
*   **Paso 3.3: Seleccionador de Zona de Entrenamiento**
    *   *Acción:* Escribir el endpoint para recibir del usuario: "Hoy haré: Pecho".
*   **Paso 3.4: Dashboard Visual para el Cliente**
    *   *Acción:* En la App Cliente, dibujar gráficos circulares atractivos. Ej: "Aforo Actual: 50 Personas. (40% Pierna, 30% Cardio...)".

---

## 🚀 Acción Inmediata (Hoy):
Para no perder impulso, ¿qué punto del plan ejecutamos ahora mismo?:
1.  **Ejecutar el Paso 1.1 y 1.2:** Subir el backend arreglado y forzar una prueba real en el Punto de Venta (POS) / Módulo de Caja.
2.  **Ejecutar el Paso 2.2:** Programar la UI de validación de identidad (La tarjeta gigante con la Super-Foto) en el `CheckinScreen` de Flutter.
