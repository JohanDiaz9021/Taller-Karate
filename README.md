# Taller Karate - Pruebas de Caja Negra

Pruebas de API con Karate Framework sobre
`https://taller-de-tecnicas-de-prueba-de-caja.onrender.com/api/`.

| Bloque | Ejercicio | Técnica | Feature |
|---|---|---|---|
| 1 | Robot Cafetero Automatizado (Barista Bot) | Transición de Estados | `barista.feature` |
| 2 | Sistema de Navegación de un Dron Agrícola Autónomo | Tabla de Decisión | `dron.feature` |

Casos de prueba en Gherkin, matrices y trazabilidad: [docs/TestCases.md](docs/TestCases.md)

## Ejecución local (Windows / PowerShell)

```powershell
.\gradlew.bat test
.\gradlew.bat test "-Dkarate.options=--tags @smoke"
.\gradlew.bat test "-Dkarate.options=--tags @smoke,@regression"
.\gradlew.bat test "-Dkarate.options=--tags @Issue-9"
```

Reporte: `target/karate-reports/karate-summary.html`

## Trazabilidad Issues ↔ Escenarios

| Issue | Título | Tag | Feature |
|---|---|---|---|
| #1 | [API] Barista Bot - T1 En Espera → Moliendo | `@smoke @Issue-1` | `barista.feature` |
| #2 | [API] Barista Bot - T2 Moliendo → Calentando Agua | `@regression @Issue-2` | `barista.feature` |
| #3 | [API] Barista Bot - T3 Calentando Agua → Sirviendo | `@regression @Issue-3` | `barista.feature` |
| #4 | [API] Barista Bot - T4 Sirviendo → En Espera | `@regression @Issue-4` | `barista.feature` |
| #5 | [API] Barista Bot - T5 Moliendo → Error de Insumos | `@regression @Issue-5` | `barista.feature` |
| #6 | [API] Barista Bot - T6 Calentando Agua → Error de Insumos | `@regression @Issue-6` | `barista.feature` |
| #7 | [API] Barista Bot - T7 Sirviendo → Error de Insumos | `@regression @Issue-7` | `barista.feature` |
| #8 | [API] Barista Bot - T8 Error de Insumos → En Espera | `@smoke @Issue-8` | `barista.feature` |
| #9 | [API] Barista Bot - Transiciones inválidas no cambian el estado | `@regression @Issue-9` | `barista.feature` |
| #10 | [API] Dron Agrícola - R1 Obstáculo cercano ejecuta esquive | `@regression @Issue-10` | `dron.feature` |
| #11 | [API] Dron Agrícola - R2/R3 Viento o batería baja activan RTL | `@regression @Issue-11` | `dron.feature` |
| #12 | [API] Dron Agrícola - R4 Condiciones normales continúa ruta | `@smoke @Issue-12` | `dron.feature` |

## Labels

El pipeline asigna estos labels al issue según el resultado:

| Label | Color |
|---|---|
| `status:passed` | verde |
| `status:failed` | rojo |
| `status:skipped` | amarillo |
| `bug` | rojo oscuro |

## Actualización automática de Issues

Actions → *CI / CD Pipeline* → **Run workflow** → tag `@Issue-N` (también acepta `@GH-N`).
El pipeline ejecuta ese escenario, comenta el resultado en el issue #N con el enlace a
la corrida y reemplaza el label `status:*`.

En `push` / `pull_request` se ejecuta automáticamente `@smoke`.

## Notas

- El API guarda un único estado compartido por máquina: cada escenario reinicia y verifica el
  estado antes de enviar el evento (`parallel(1)` en el Runner).
- El API en Render se suspende sin tráfico; la primera petición puede tardar ~1 min
  (`readTimeout` = 60 s).
