# Training Planner - fases de desarrollo

## Fase 1 - Proyecto, modelos y navegación básica

Estado: implementada en código. Pendiente de compilación real en un entorno con Xcode disponible. Se ha añadido un workflow de GitHub Actions para compilar en macOS al subir el proyecto a GitHub.

- Proyecto SwiftUI nativo para iPhone.
- SwiftData configurado en la entrada de la app.
- Modelos persistentes: `Exercise`, `WeeklyPlan`, `WeeklyPlanDay`, `PlannedExercise`.
- Enums de dominio para nivel, objetivo, fuente de vídeo y días de la semana.
- Navegación base con `TabView` y `NavigationStack`.
- Pantallas base: inicio, ejercicios, semanas, generador, historial y ajustes.

## Fase 2 - CRUD completo de ejercicios

Estado: implementada en código. Pendiente de compilación real en GitHub Actions.

- Listado real con SwiftData.
- Crear, editar y eliminar ejercicios.
- Buscador y filtros.
- Tarjetas visuales.

## Fase 3 - Detalle de ejercicio

Pendiente.

- Vídeo externo o local.
- Imagen opcional.
- Explicación, instrucciones, series, repeticiones, tiempos, descanso y frecuencia.
- Acciones de edición y añadir a tabla semanal.

## Fase 4 - Tabla semanal manual

Pendiente.

- Crear tabla semanal.
- Añadir ejercicios a cada día.
- Personalizar series, repeticiones, tiempo, descanso y notas.
- Marcar ejercicios como completados.

## Fase 5 - Generador automático

Pendiente.

- Selección por objetivo, nivel, días disponibles y duración.
- Priorización por categorías o grupos musculares.
- Distribución lógica por días.

## Fase 6 - Historial y duplicado

Pendiente.

- Historial de tablas semanales.
- Duplicar semanas anteriores.
- Eliminar y editar tablas existentes.

## Fase 7 - Pulido y preparación futura

Pendiente.

- Mejoras visuales.
- Revisión de usabilidad.
- Preparación para login, nube, PDF, compartir y panel web.
