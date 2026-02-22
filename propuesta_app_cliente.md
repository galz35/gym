# Propuesta: Aplicación Móvil para Clientes (GymPro Client App)

Basado en la visión de resolver problemas reales de los gimnasios y mejorar la experiencia del usuario final, proponemos la creación de una **App para Clientes** que se conecte con el backend actual de GymPro.

## 1. Módulo Administrativo y Acceso (Ya en progreso en Admin)
*   **Reconocimiento Visual Rápido:** Mostrar la foto grande del cliente en la pantalla de recepción (App Admin) en cuanto pase su credencial, pin o biometría. Esto elimina instantáneamente el préstamo de membresías; el recepcionista ve de inmediato si el rostro coincide con el perfil que pagó.

## 2. Pantalla de "Aforo en Tiempo Real" (Innovación Principal)
Esta es una característica "Killer" (diferenciadora clave) para la App del Cliente:
*   **Radar de Ocupación:** Mostrar al cliente el nivel de ocupación general del gimnasio antes de salir de su casa (Ej: "Ocupación al 30% - Buen momento para entrenar" o "Ocupación al 90% - Muy lleno").
*   **Mapa de Calor por Grupo Muscular (Opcional & Premium):** 
    *   *Concepto:* Cuando el cliente ingresa (Check-in), la app le pregunta rápido: "¿Qué vas a entrenar hoy?" (Opciones: Pecho/Tríceps, Espalda/Bíceps, Pierna, Cardio, Full Body).
    *   *Valor:* Los clientes que están en casa pueden ver en la app no solo cuánta gente hay, sino **qué están haciendo**. Si la app dice "20 personas entrenando Pierna", el cliente sabe que las prensas y sentadillas estarán ocupadas y puede decidir ir más tarde o cambiar su rutina a Pecho ese día.
    *   *Beneficio:* Evita la frustración de esperar por máquinas y distribuye de forma natural a la gente por las instalaciones.

## 3. Características Adicionales de la App Cliente
*   **Mi Código QR / Carnet Digital:** Para ingresar al gimnasio sin tarjeta física.
*   **Estado de Cuenta y Suscripción:** Ver cuántos días o visitas le quedan a su membresía y recibir notificaciones de pago (evita que se sientan "sorprendidos" al llegar y no poder entrar).
*   **Rutinas y Progreso:** (Opcional) Ver su rutina asignada por el coach.

---
*Nota: La arquitectura de backend de NestJS actual ya soporta múltiples sucursales y clientes, lo que hace que crear una API para esta App de Clientes sea un proceso directo y natural como Fase 2 del proyecto.*
