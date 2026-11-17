# PlainPlease

> **«Entiende el texto sin perder lo importante»**

![Android](https://img.shields.io/badge/Android-Offline--First-6D28D9)
![Flutter](https://img.shields.io/badge/Flutter-Material%203-blue)
![Zero Telemetry](https://img.shields.io/badge/Telemetr%C3%ADa-0%25-success)

**PlainPlease** te ayuda a leer contratos, cláusulas legales, notificaciones administrativas o informes densos dividiéndolos en bloques manejables, resaltando tecnicismos mediante un glosario editable y manteniendo intactas las cifras, porcentajes y fechas clave.

---

## Características principales

- **Desglose por bloques**: separa textos largos párrafo a párrafo para leerlos con calma y marcar cada bloque como revisado.
- **Glosario claro offline**: incluye definiciones cotidianas de términos jurídicos/administrativos frecuentes (*tácita reconducción*, *desistimiento*, *demora*, *subrogación*, *silencio administrativo*) y te permite añadir tus propios términos.
- **Protección de datos clave**: detecta automáticamente importes (`€`/`EUR`), porcentajes (`%`), plazos (`días`, `meses`) y fechas para que nunca se pierdan al simplificar.
- **IA opcional BYOK (gratuita)**: desactivada por defecto; permite generar explicaciones claras bloque a bloque marcadas como borrador hasta tu confirmación.

---

## Privacidad y política de gratuidad

- Sin registro, sin anuncios ni telemetría.
- Los documentos y el glosario permanecen únicamente en SQLite local.
- Pantalla de **revisión y redacción previa** (oculta emails, IBAN y DNI con un toque) antes de cualquier llamada BYOK gratuita.

---

## Instalación y compilación local

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

---

## Documentación adicional

- [DEPENDENCIES.md](DEPENDENCIES.md) · [CONTRIBUTING.md](CONTRIBUTING.md)
