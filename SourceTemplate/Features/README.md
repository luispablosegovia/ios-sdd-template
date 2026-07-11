# Features/
Una carpeta por feature, autocontenida:

    Features/Onboarding/
    ├── OnboardingView.swift    ← SwiftUI, tonta, declarativa
    └── OnboardingModel.swift   ← @Observable, acá vive la lógica

Reglas: las features NO se importan entre sí (comparten vía Core/).
Cada feature nace de un spec en specs/. `_Template/` muestra el patrón: copiala,
renombrala y borrá la original cuando arranques tu primera feature real.
