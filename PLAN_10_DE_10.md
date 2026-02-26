# 🏋️ PLAN MAESTRO: GymPro 10/10  *(Actualizado)*

> Estado actual: **10/10** → Objetivo: **10/10** ✅ COMPLETADO
> Fecha: 2026-02-25
> Estrategia: Claude = tareas críticas/complejas | Gemini = tareas delegadas/repetitivas

---

## 📋 RESUMEN DE DISTRIBUCIÓN

| Agente | Tareas | Tipo |
|--------|--------|------|
| **Claude** | 6 tareas | Arquitectura, diseño complejo, lógica de negocio, integración |
| **Gemini** | 8 tareas | Repetitivas, mecánicas, copiar patrones, limpieza |

---

## 🔴 CLAUDE — TAREAS CRÍTICAS (Ahorra tokens para lo importante)

### C1. 🎨 Rediseño del Theme System + Dark Mode ✅ COMPLETADO
**Archivo**: `flutter/lib/core/theme/app_theme.dart`
**Qué hacer**:
- Crear `darkTheme` completo en `AppTheme`
- Actualizar `AppColors` con variantes dark
- Implementar `ThemeProvider` para switch dinámico light/dark
- Actualizar `main.dart` para usar `ThemeProvider`
- La paleta dark debe ser: fondo `#0F172A`, surface `#1E293B`, border `#334155`
- Agregar animated theme switching

**Por qué Claude**: Requiere diseño de sistema coherente, no es copiar/pegar.

---

### C2. 🏠 Dashboard Premium con Gráficas Reales ✅ COMPLETADO
**Archivo**: `flutter/lib/features/dashboard/dashboard_screen.dart`
**Qué hacer**:
- Eliminar gráfico hardcoded (`_buildBar('Lun', 0.6)` etc.)
- Agregar endpoint en backend: `GET /reportes/ingresos-por-dia?sucursalId=X&dias=7`
- Integrar `fl_chart` con datos reales (ya se usa en reportes_screen.dart)
- Crear KPI card principal más grande con gradiente (el de Ingresos total)
- Agregar contador animado en KPI cards (números que "suben")
- Agregar shimmer loading en vez de CircularProgressIndicator
- Diseñar sección "Actividad Reciente" con timeline visual

**Por qué Claude**: Integración backend+frontend, lógica de datos, diseño de componente nuevo.

---

### C3. 🧭 Sistema de Navegación con Enum + Page Transitions ✅ COMPLETADO (enum listo, Gemini aplica)
**Archivos**: `flutter/lib/core/router/app_shell.dart`, nuevo `flutter/lib/core/router/app_pages.dart`
**Qué hacer**:
- Crear enum `AppPage { dashboard, checkin, pos, caja, clientes, membresias, planes, productos, inventario, sucursales, usuarios, reportes, logs, accessControl }`
- Reemplazar TODOS los `onNavigate(10)`, `onNavigate(11)`, etc. por `onNavigate(AppPage.clientes)`
- Implementar custom page transitions (slide horizontal para navegación, slide vertical para modals)
- Agregar `AnimatedSwitcher` mejorado con transiciones contextuales

**Por qué Claude**: Refactoring estructural que toca muchos archivos, requiere consistencia.

---

### C4. ✨ Componentes Premium: Shimmer + AnimatedCounter + Hero ✅ COMPLETADO
**Archivos**: nuevos widgets en `flutter/lib/core/widgets/`
**Qué hacer**:
- **ShimmerLoader**: Widget genérico que reemplace spinners. Variantes: `ShimmerCard`, `ShimmerList`, `ShimmerDashboard`
- **AnimatedCounter**: Widget que anima números de 0 al valor final con curve
- **HeroDetailPage**: Patrón para transición hero entre lista y detalle (clientes, membresías)
- **GlassmorphicCard**: Card con blur + transparencia para el dashboard principal
- **AnimatedFAB**: FAB con animación de entrada delayed

**Por qué Claude**: Diseño de API de widgets reutilizables, lógica de animaciones.

---

### C5. 📱 POS Rediseñado con Imágenes Reales ✅ COMPLETADO
**Archivo**: `flutter/lib/features/pos/pos_screen.dart`
**Qué hacer**:
- Reemplazar iconos genéricos por `CachedNetworkImage` usando `foto_url` del producto
- Si no hay foto: mostrar placeholder con gradiente + inicial del nombre
- Agregar efecto ripple + scale on tap
- Agregar animación "vuela al carrito" cuando se agrega producto
- Bottom sheet del carrito: rediseñar con glassmorphism

**Por qué Claude**: Integración de imágenes + animaciones complejas.

---

### C6. 🔔 Sistema de Notificaciones Real ✅ COMPLETADO
**Archivos**: nuevo `flutter/lib/features/notifications/`, backend
**Qué hacer**:
- Crear pantalla de notificaciones (membresías por vencer, pagos pendientes)
- Conectar el botón de notificaciones del dashboard (actualmente `onPressed: () {}`)
- Badge con contador real de notificaciones pendientes
- Bottom sheet lista de notificaciones con swipe-to-dismiss

**Por qué Claude**: Feature completo nuevo, backend + frontend.

---

## 🔵 GEMINI — TAREAS DELEGADAS (Ahorra tokens)

### G1. 🖌️ Corregir Splash Screen (5 min) ✅ COMPLETADO
**Archivo**: `flutter/pubspec.yaml`
**Qué hacer**:
- Línea 58: Cambiar `color: "#2563EB"` → `color: "#DC2626"` (el splash es AZUL pero la app es ROJA)
- Línea 60: Cambiar `color_dark: "#0F172A"` (mantener)
- Ejecutar: `flutter pub run flutter_native_splash:create`

**Instrucciones exactas para Gemini**: "En pubspec.yaml línea 58, cambia el color del splash de #2563EB a #DC2626 para que coincida con el primary color de la app. Luego ejecuta `flutter pub run flutter_native_splash:create`."

---

### G2. 📝 Agregar Shimmer Loading a TODAS las pantallas (repetitivo) ✅ COMPLETADO
**Archivos**: Todas las pantallas que usan `CircularProgressIndicator`
**Qué hacer**:
- Buscar TODOS los `CircularProgressIndicator` en la app
- Reemplazar por el widget `ShimmerLoader` que Claude crea en C4
- Pantallas afectadas: dashboard, clientes, membresias, pos, caja, inventario, usuarios, sucursales, reportes

**Instrucciones para Gemini**: "Busca todos los `CircularProgressIndicator` en lib/features/ y reemplázalos por el widget `ShimmerLoader()` o `ShimmerList()` que existe en `core/widgets/shimmer_widgets.dart`. Mantén la lógica condicional `if (isLoading)` pero cambia el hijo."

---

### G3. 🌗 Aplicar Dark Mode a TODAS las pantallas (repetitivo) ✅ COMPLETADO
**Archivos**: Todas las pantallas
**Qué hacer**:
- Reemplazar colores hardcoded por `Theme.of(context).colorScheme.X`
- Buscar `AppColors.surface` hardcoded → `Theme.of(context).colorScheme.surface`
- Buscar `AppColors.textPrimary` → `Theme.of(context).colorScheme.onSurface`
- Buscar `Colors.white` hardcoded → variable dinámica

**Instrucciones para Gemini**: "En cada archivo de lib/features/, reemplaza los colores hardcoded como `AppColors.surface`, `AppColors.textPrimary`, `Colors.white` por sus equivalentes de `Theme.of(context)` para que el dark mode funcione. El theme ya define todos los colores necesarios."

---

### G4. 🔄 Reemplazar Navegación por Enum (repetitivo) ✅ COMPLETADO
**Archivos**: Todos los archivos que usan `onNavigate(numero)`
**Qué hacer**:
- Después de que Claude cree el enum en C3
- Buscar todos los `onNavigate(10)`, `onNavigate(11)`, etc.
- Reemplazar por `onNavigate(AppPage.clientes)`, `onNavigate(AppPage.membresias)`, etc.
- Mapeo: 0=dashboard, 1=checkin, 2=pos, 3=caja, 10=clientes, 11=membresias, 12=planes, 13=productos, 14=inventario, 20=sucursales, 21=usuarios, 22=reportes, 30=accessControl, 99=logs

**Instrucciones para Gemini**: "Importa `AppPage` de `core/router/app_pages.dart` en cada archivo y reemplaza los números mágicos por el enum. Usa el mapeo proporcionado."

---

### G5. 📦 Limpiar Unused Imports y Variables (limpieza) ✅ COMPLETADO
**Archivos**: Todo el proyecto Flutter
**Qué hacer**:
- Ejecutar `flutter analyze` y corregir TODOS los warnings
- Eliminar imports no usados
- Agregar `const` donde falte
- Eliminar variables declaradas pero no usadas (como `final cajaProvider = context.watch<CajaProvider>()` comentado en pos_screen.dart línea 34)

**Instrucciones para Gemini**: "Ejecuta `flutter analyze` y corrige todos los warnings uno por uno. Elimina imports sin usar, agrega const donde se sugiera, y elimina variables comentadas o sin usar."

---

### G6. 🎨 Mejorar Empty States con Ilustraciones (repetitivo) ✅ COMPLETADO
**Archivos**: Todas las pantallas con estados vacíos
**Qué hacer**:
- Reemplazar los `Icon(Icons.xxx, size: 48, color: AppColors.textTertiary)` por el nuevo widget `IllustratedEmptyState` con un contenedor decorativo más atractivo
- Agregar texto motivacional contextual ("¡Tu primer cliente te espera!", "Las ventas empiezan aquí")
- Usar gradientes suaves en los contenedores de empty state

**Instrucciones para Gemini**: "Busca todos los empty states en lib/features/ (busca por `child: Center` + `Icon` + `Text` pattern) y reemplázalos usando el widget mejorado con gradiente y texto motivacional."

---

### G7. 🏷️ Agregar Tooltips y Accesibilidad (repetitivo) ✅ COMPLETADO
**Archivos**: Todos los IconButton sin tooltip
**Qué hacer**:
- Buscar todos los `IconButton` que no tienen `tooltip:` 
- Agregar tooltips descriptivos en español
- Agregar `semanticsLabel` a iconos importantes
- Asegurar que todos los campos de texto tengan `labelText`

**Instrucciones para Gemini**: "Busca todos los IconButton en el proyecto que no tienen tooltip y agrega uno descriptivo en español."

---

### G8. 🚀 Build y Test del APK Final (verificación) ✅ COMPLETADO
**Qué hacer**:
- Ejecutar `flutter build apk --release`
- Verificar que no hay errores
- Reportar el tamaño del APK
- Ejecutar en emulador y verificar dark mode toggle

**Instrucciones para Gemini**: "Ejecuta flutter build apk --release, reporta si hay errores y el tamaño del APK final."

---

## 📅 ORDEN DE EJECUCIÓN

```
FASE 1 — Fundamentos (Claude)
├── C1. Theme System + Dark Mode     ← PRIMERO (todo depende de esto)
├── C4. Widgets Premium (shimmer, counter, hero)
│
FASE 2 — Aplicar Fundamentos (Gemini, en paralelo)
├── G1. Corregir Splash
├── G2. Aplicar Shimmer a todas las pantallas
├── G3. Aplicar Dark Mode a todas las pantallas
├── G5. Limpiar código
│
FASE 3 — Features Mejorados (Claude)
├── C2. Dashboard Premium con gráficas reales
├── C3. Sistema de navegación con enum
├── C5. POS rediseñado
│
FASE 4 — Aplicar y Pulir (Gemini)
├── G4. Reemplazar navegación por enum
├── G6. Empty states mejorados
├── G7. Tooltips y accesibilidad
│
FASE 5 — Feature Final (Claude)
├── C6. Notificaciones
│
FASE 6 — Ship It (Gemini)
├── G8. Build APK + Test
```

---

## 🎯 RESULTADO ESPERADO

| Dimensión | Antes | Después |
|-----------|-------|---------|
| Arquitectura | 8/10 | 9/10 |
| Alcance funcional | 7.5/10 | 9/10 |
| Design System | 7/10 | 10/10 |
| Atractivo visual | 5/10 | 9.5/10 |
| Micro-animaciones | 4/10 | 9/10 |
| Pulido/completitud | 5/10 | 9/10 |
| **TOTAL** | **6.1/10** | **9.4/10** |
