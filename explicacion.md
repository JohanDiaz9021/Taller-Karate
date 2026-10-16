# Explicación del proyecto - Taller Karate

Pruebas de caja negra sobre la API
`https://taller-de-tecnicas-de-prueba-de-caja.onrender.com/api/` con **Karate 1.4.1 + Gradle + JUnit 5**
(JDK 21 en el pipeline).

## 1. Ejercicios trabajados

| Bloque | Ejercicio | Técnica | Feature | Issues |
|---|---|---|---|---|
| 1 | **1.2 Robot Cafetero Automatizado (Barista Bot)** | Transición de Estados | [barista.feature](src/test/resources/features/barista.feature) | #1 – #9 |
| 2 | **2.3 Sistema de Navegación de un Dron Agrícola Autónomo** | Tabla de Decisión | [dron.feature](src/test/resources/features/dron.feature) | #10 – #12 |

**Totales:** 12 escenarios, 12 issues y 38 ejecuciones (los Scenario Outline se ejecutan una vez por fila de `Examples`).

## 2. Estructura del proyecto

```
.github/
  ISSUE_TEMPLATE/caso-de-prueba.md   Plantilla de issue (tag @Issue-N + feature)
  workflows/ci.yml                   Pipeline: ejecuta pruebas y actualiza issues
docs/TestCases.md                    Matrices, tabla de decisión, Gherkin y trazabilidad
src/test/java/runner/Runner.java     Ejecuta todos los features con parallel(1)
src/test/resources/
  karate-config.js                   baseUrl y timeouts (Render tarda en despertar)
  logback-test.xml                   Configuración de logs
  features/
    barista.feature                  Bloque 1 - Transición de estados
    dron.feature                     Bloque 2 - Tabla de decisión
    helpers/evento.feature           Helper: dispara un evento (@ignore)
    helpers/estado.feature           Helper: consulta el estado actual (@ignore)
build.gradle                         Dependencias (karate-junit5, logback)
```

## 3. Bloque 1 - Barista Bot (Transición de Estados)

### Cómo funciona

El robot es una máquina de **5 estados × 6 eventos = 30 combinaciones**: **8 válidas** y **22 inválidas**.

| Estado \ Evento | Iniciar Pedido | Terminar Molienda | Alcanzar Temperatura | Terminar Llenado | Sin Ingredientes | Recargar y Reiniciar |
|---|---|---|---|---|---|---|
| **S1 En Espera** | → S2 | ✗ | ✗ | ✗ | ✗ | ✗ |
| **S2 Moliendo** | ✗ | → S3 | ✗ | ✗ | → S5 | ✗ |
| **S3 Calentando Agua** | ✗ | ✗ | → S4 | ✗ | → S5 | ✗ |
| **S4 Sirviendo** | ✗ | ✗ | ✗ | → S1 | → S5 | ✗ |
| **S5 Error de Insumos** | ✗ | ✗ | ✗ | ✗ | ✗ | → S1 |

Flujo de cada escenario:

1. **Background:** reinicia el robot (`POST barista-bot/reiniciar`) y verifica que esté en *En Espera*.
2. **`moveTo([...])`:** envía los eventos necesarios para llegar al estado inicial del caso.
3. **`getState()`:** confirma que el robot está en ese estado.
4. Envía el **evento bajo prueba** (`POST barista-bot/evento`).
5. Valida la **respuesta** y vuelve a consultar el **estado** para confirmar el resultado.

### Escenarios positivos - T1 a T8 (Issues #1–#8)

Son positivos porque el evento **sí está permitido** en el estado actual, así que el sistema debe aceptarlo y cambiar de estado:

```gherkin
And match response contains { estadoAnterior: 'Moliendo', estadoNuevo: 'Calentando Agua', valida: true, accion: null }
And match getState() == 'Calentando Agua'
```

| Caso | Transición | Tipo de camino |
|---|---|---|
| T1 – T4 | En Espera → Moliendo → Calentando Agua → Sirviendo → En Espera | Camino feliz (ciclo completo del café) |
| T5 – T7 | Moliendo / Calentando Agua / Sirviendo → Error de Insumos | Camino de error **definido** (acción `Interrumpir flujo`) |
| T8 | Error de Insumos → En Espera | Recuperación (acción `Restaurar servicio`) |

> T5–T7 representan una falla del negocio, pero **siguen siendo positivos**: la transición está definida en la
> especificación y el sistema debe ejecutarla.

### Escenario negativo - Transiciones inválidas (Issue #9)

Es un `Scenario Outline` con **22 filas**, una por cada combinación marcada ✗ en la matriz.

**Por qué es negativo:** se envía un evento que **no corresponde** al estado actual (por ejemplo, *Terminar Llenado*
estando *En Espera*). Lo que se valida es que el sistema **lo rechace y no cambie de estado**:

```gherkin
And match response contains { estadoAnterior: '<estado_actual>', estadoNuevo: '<estado_actual>', valida: false, noDefinida: true }
And match getState() == '<estado_actual>'
```

> La API responde **HTTP 200** también en este caso. El escenario es negativo a nivel de **regla de negocio**
> (`valida: false`, `noDefinida: true`), no a nivel HTTP (no se espera un 400).

Cada fila de `Examples` trae el estado inicial, el `camino` de eventos para llegar a él y el evento inválido.

## 4. Bloque 2 - Dron Agrícola (Tabla de Decisión)

### Tabla de decisión

| Condiciones / Reglas | R1 | R2 | R3 | R4 |
|---|---|---|---|---|
| C1: ¿Viento > 40 km/h? | – | T | F | F |
| C2: ¿Batería < 15%? | – | – | T | F |
| C3: ¿Obstáculo a menos de 2m? | T | F | F | F |
| **Acción** | Esquive de emergencia | RTL | RTL | Continuar ruta |

Las condiciones se envían como `valores: [viento, bateria, obstaculo]` a `POST decision/dron-agricola/evaluar`.
El `Background` limpia el historial y cada escenario verifica también que la evaluación quedó registrada
(`GET decision/dron-agricola/definicion`).

### Escenarios

| Escenario | Tipo | Ejecuciones | Qué valida |
|---|---|---|---|
| R1 (#10) | Positivo | 4 | Con obstáculo siempre esquiva, sin importar viento ni batería: prueba la **prioridad** de R1 |
| R2/R3 (#11) | Positivo | 3 | Viento fuerte o batería baja sin obstáculo → RTL. Se agrupan porque comparten acción; `[T,T,F]` lo resuelve R2 |
| R4 (#12) | Positivo (camino feliz) | 1 | Sin condiciones de riesgo → continúa la ruta |

Entre todos se cubren las **8 combinaciones posibles** de las 3 condiciones (2³).

**No hay escenarios negativos** en este feature: toda combinación de entradas tiene una regla definida. Un caso
negativo requeriría entradas inválidas (por ejemplo, `valores` con 2 elementos, un texto en lugar de booleano o un
body vacío).

## 5. Diseño de las pruebas y patrón

### Lo que se implementó

El proyecto usa **Karate puro**: los pasos HTTP se escriben directamente en los `.feature`, con piezas reutilizables:

- **`Background`:** precondición común (reiniciar el sistema antes de cada escenario).
- **Helpers `@ignore`:** [evento.feature](src/test/resources/features/helpers/evento.feature) y
  [estado.feature](src/test/resources/features/helpers/estado.feature), llamados con `karate.call(...)`.
  `@ignore` evita que el Runner los ejecute como pruebas.
- **Funciones JS en el Background:** `moveTo(eventos)` y `getState()`.
- **`Scenario Outline` + `Examples`:** un escenario se escribe una vez y se ejecuta con varios datos.
- **[karate-config.js](src/test/resources/karate-config.js):** configuración global (`baseUrl`, timeouts).

### Relación con el patrón Screenplay (actor, habilidades, tareas)

**El proyecto no implementa Screenplay.** Ese patrón es propio de **Serenity BDD** y requiere clases Java
(`Actor`, `Ability` como `CallAnApi`, `Task`, `Question`, `Interaction`), que aquí no existen.
Conceptualmente, la separación sí se parece:

| Concepto Screenplay | Equivalente en este proyecto |
|---|---|
| **Actor** | Implícito: el "operador" de la narrativa (`Como operador de la cafetería...`) |
| **Habilidad** (llamar a una API) | `* url baseUrl` + `karate-config.js`; Karate ya incluye el cliente HTTP |
| **Tarea / Interacción** | `evento.feature` (dispara un evento) y `moveTo([...])` (encadena eventos) |
| **Pregunta** | `estado.feature` y `getState()` (consultan el estado actual) |
| **Aserción** (`seeThat`) | `match response contains {...}` y `match getState() == '...'` |

## 6. Tags

| Tag | Uso |
|---|---|
| `@api` | Todos los features de API |
| `@transicionEstados`, `@tablaDecision` | Técnica de prueba |
| `@baristaBot`, `@dronAgricola` | Ejercicio |
| `@smoke` | Casos críticos (T1, T8, R4); se ejecutan en cada push / PR |
| `@regression` | Resto de casos |
| `@Issue-N` | Vincula el escenario con el issue #N de GitHub |
| `@ignore` | Helpers que no se ejecutan solos |

## 7. Ejecución y CI

```powershell
.\gradlew.bat test                                        # todo
.\gradlew.bat test "-Dkarate.options=--tags @smoke"       # solo smoke
.\gradlew.bat test "-Dkarate.options=--tags @Issue-9"     # un issue
```

Reporte: `target/karate-reports/karate-summary.html`

- **Runner con `parallel(1)`:** la API guarda un único estado compartido, así que los escenarios no deben solaparse.
- **Timeouts:** Render suspende el servicio sin tráfico; la primera petición puede tardar ~1 min (`readTimeout` 60 s).
  El CI además hace un `curl` previo para despertarlo.
- **Pipeline ([ci.yml](.github/workflows/ci.yml)):**
  - `push` / `pull_request` a `main` o `develop` → ejecuta `@smoke`.
  - `workflow_dispatch` con tag `@Issue-N` (o `@GH-N`) → ejecuta ese escenario, comenta el resultado en el issue #N
    y reemplaza su label `status:*`.
  - Sube `karate-reports` y `test-results` como artifacts.

## 8. Diferencias con el README

| Punto | Detalle |
|---|---|
| Labels | El README lista `status:skipped` y `bug`, pero el CI solo asigna `status:passed`, `status:failed` o `status:unknown` |
| Número de ejercicio | El README no indica 1.2 y 2.3 (solo aparece en `docs/TestCases.md`) |
| Positivos / negativos | El README no explica qué escenarios son positivos o negativos |
| Diseño | No describe helpers, funciones, Background ni la organización de tags |
| Patrón | No aclara la relación con Screenplay |
| Requisitos | No menciona JDK 21 ni la versión de Karate |
| Totales | Los 12 escenarios / 38 ejecuciones solo están en `docs/TestCases.md` |
