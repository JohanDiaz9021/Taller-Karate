# Taller Karate - Pruebas de Caja Negra

Pruebas de API con Karate Framework sobre
`https://taller-de-tecnicas-de-prueba-de-caja.onrender.com/api/`.

## Ejecución local (Windows / PowerShell)

```powershell
.\gradlew.bat test
.\gradlew.bat test "-Dkarate.options=--tags @smoke"
.\gradlew.bat test "-Dkarate.options=--tags @smoke,@regression"
.\gradlew.bat test "-Dkarate.options=--tags @Issue-2"
```

Reporte: `target/karate-reports/karate-summary.html`

## Trazabilidad Issues ↔ Escenarios

Crear los issues **en este orden** para que GitHub asigne estos números
(plantilla: Issues → New issue → *Caso de prueba automatizado*):

| Issue | Título | Tag | Feature |
|---|---|---|---|
| #1 | [API] Barista Bot - Consultar estado inicial | `@smoke @Issue-1` | `barista.feature` |
| #2 | [API] Barista Bot - Iniciar pedido pasa a Moliendo | `@smoke @Issue-2` | `barista.feature` |
| #3 | [API] Barista Bot - Transiciones válidas del flujo feliz | `@regression @Issue-3` | `barista.feature` |
| #4 | [API] Barista Bot - Sin ingredientes y recarga | `@regression @Issue-4` | `barista.feature` |
| #5 | [API] Barista Bot - Evento no definido no cambia estado | `@regression @Issue-5` | `barista.feature` |
| #6 | [API] Barista Bot - Evento desconocido retorna 400 | `@regression @Issue-6` | `barista.feature` |
| #7 | [API] Barista Bot - Historial registra transiciones | `@regression @Issue-7` | `barista.feature` |

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

- `onOff.feature` está marcado `@ignore`: el ejercicio `encendido-apagado` no existe en el API
  (ver `GET /api/ejercicios`).
- El API en Render se suspende sin tráfico; la primera petición puede tardar ~1 min
  (`readTimeout` = 60 s).
