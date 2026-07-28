# Architecture Decision Records (ADRs)

Un archivo por decisión importante: `NNNN-titulo-corto.md`.
Nunca se editan retroactivamente: si una decisión cambia, se escribe
un ADR nuevo que la reemplaza y se marca el viejo como "Superseded".

Pedirle al planner: "escribí el ADR de esta decisión" y listo.

Toda dependencia externa nueva requiere un ADR antes de implementar. Usá
`package-decision-template.md` para documentar alternativas Apple-native,
licencia, mantenimiento, dependencias transitivas, impacto de seguridad/privacidad
y plan de salida.
