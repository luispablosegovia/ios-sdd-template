# Arquitectura

> Documento vivo. Actualizalo cuando cambien decisiones estructurales
> (idealmente, pedile al planner que lo haga al cerrar cada feature grande).

## Visión general

Patrón **MV con @Observable** (el "MVVM moderno" de SwiftUI): las vistas son
declarativas y tontas; el estado y la lógica viven en modelos `@Observable`;
los servicios compartidos viven en `Core/` y se inyectan por Environment.

```
┌────────────┐     observa      ┌──────────────────┐    usa    ┌───────────┐
│ SwiftUI     │ ───────────────▶ │ @Observable       │ ────────▶ │ Core/      │
│ Views       │ ◀─────────────── │ Feature Models    │           │ Services   │
└────────────┘   acciones        └──────────────────┘           └───────────┘
                                          │
                                          ▼
                                   SwiftData (persistencia)
```

## Capas

| Capa | Carpeta | Responsabilidad | Testeo |
|------|---------|-----------------|--------|
| UI | `Features/*/…View.swift` | Layout, binding, navegación | Previews + UI tests de flujos críticos |
| Estado | `Features/*/…Model.swift` | Lógica de la feature, orquestación | Swift Testing (unit) — acá va el grueso |
| Servicios | `Core/Networking`, `Core/Persistence` | HTTP, SwiftData, sistema | Swift Testing con dobles |
| Diseño | `Core/DesignSystem` | Tokens, componentes reutilizables | Previews |

## Reglas estructurales

1. `Features/` no se importan entre sí; comparten a través de `Core/`.
2. Todo servicio se define detrás de un protocolo si necesita doble de test.
3. Navegación con `NavigationStack` + rutas tipadas (enum por feature).
4. Concurrencia: modelos de UI `@MainActor`; trabajo pesado en actores o
   funciones `async` de servicios.

## Decisiones registradas

Ver `docs/decisions/` (ADRs). Toda dependencia externa nueva y todo cambio
de patrón estructural requieren un ADR.
