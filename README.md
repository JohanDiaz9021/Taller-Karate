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

## Explicación del código

Explicación detallada (matrices, tablas y diferencias con este README): [explicacion.md](explicacion.md)

### 1. Feature Barista Bot (Ejercicio 1.2 - Transición de Estados)

Archivo: [`src/test/resources/features/barista.feature`](src/test/resources/features/barista.feature)

| Líneas | Qué hace |
|---|---|
| [1](src/test/resources/features/barista.feature#L1) | Tags `@api @transicionEstados @baristaBot`: tipo de prueba, técnica y ejercicio |
| [2-5](src/test/resources/features/barista.feature#L2-L5) | Historia de usuario: *como operador quiero controlar el ciclo del robot...* |
| [7-8](src/test/resources/features/barista.feature#L7-L8) | Matriz: 5 estados × 6 eventos = 30 combinaciones (8 válidas, 22 inválidas) |
| [10-20](src/test/resources/features/barista.feature#L10-L20) | **Background**, se ejecuta antes de cada escenario |
| [11](src/test/resources/features/barista.feature#L11) | `url baseUrl`: URL de la API |
| [13](src/test/resources/features/barista.feature#L13) | `slug = 'barista-bot'`: nombre de la máquina de estados en la API |
| [14](src/test/resources/features/barista.feature#L14) | `moveTo(eventos)`: lleva el robot a un estado enviando eventos en orden |
| [15](src/test/resources/features/barista.feature#L15) | `getState()`: consulta el estado actual del robot |
| [17-20](src/test/resources/features/barista.feature#L17-L20) | `POST barista-bot/reiniciar` y verifica que quede en *En Espera* |

### 2. Escenarios positivos (T1 – T8, Issues #1 – #8)

Ejemplo: **T1**, [barista.feature:26-37](src/test/resources/features/barista.feature#L26-L37)

| Líneas | Qué hace |
|---|---|
| [26](src/test/resources/features/barista.feature#L26) | `@smoke` (caso crítico, corre en cada push) y `@Issue-1` (vincula con el issue #1) |
| [29](src/test/resources/features/barista.feature#L29) | Verifica con `getState()` que el robot esté en *En Espera* |
| [31-34](src/test/resources/features/barista.feature#L31-L34) | `POST barista-bot/evento` con `{ evento: 'Iniciar Pedido' }`, espera status 200 |
| [36](src/test/resources/features/barista.feature#L36) | Valida `estadoAnterior: 'En Espera'`, `estadoNuevo: 'Moliendo'`, `valida: true` |
| [37](src/test/resources/features/barista.feature#L37) | Confirma que el estado realmente cambió a *Moliendo* |

**Por qué es positivo:** el evento está permitido en el estado actual, así que el sistema debe aceptarlo y
cambiar de estado.

**T5 – T7** ([líneas 72-103](src/test/resources/features/barista.feature#L72-L103)) también son positivos: aunque
representan una falla (*Sin Ingredientes*), la transición a *Error de Insumos* está definida en la especificación.
Se valida `valida: true` y `accion: 'Interrumpir flujo'` (por ejemplo, en la
[línea 80](src/test/resources/features/barista.feature#L80)).

| Caso | Líneas | Transición |
|---|---|---|
| T1 | [26](src/test/resources/features/barista.feature#L26) | En Espera → Moliendo |
| T2 | [39](src/test/resources/features/barista.feature#L39) | Moliendo → Calentando Agua |
| T3 | [50](src/test/resources/features/barista.feature#L50) | Calentando Agua → Sirviendo |
| T4 | [61](src/test/resources/features/barista.feature#L61) | Sirviendo → En Espera |
| T5 | [72](src/test/resources/features/barista.feature#L72) | Moliendo → Error de Insumos |
| T6 | [83](src/test/resources/features/barista.feature#L83) | Calentando Agua → Error de Insumos |
| T7 | [94](src/test/resources/features/barista.feature#L94) | Sirviendo → Error de Insumos |
| T8 | [105](src/test/resources/features/barista.feature#L105) | Error de Insumos → En Espera |

### 3. Escenario negativo (Transiciones inválidas, Issue #9)

[barista.feature:120-157](src/test/resources/features/barista.feature#L120-L157)

| Líneas | Qué hace |
|---|---|
| [120](src/test/resources/features/barista.feature#L120) | `@regression @Issue-9` |
| [121](src/test/resources/features/barista.feature#L121) | **Scenario Outline**: plantilla que se ejecuta una vez por cada fila de `Examples` |
| [123-124](src/test/resources/features/barista.feature#L123-L124) | `moveTo(<camino>)` lleva el robot al estado de la fila y lo confirma |
| [126-129](src/test/resources/features/barista.feature#L126-L129) | Envía un evento **no permitido** en ese estado |
| [131](src/test/resources/features/barista.feature#L131) | Valida `estadoNuevo == estadoAnterior`, `valida: false`, `noDefinida: true` |
| [132](src/test/resources/features/barista.feature#L132) | Confirma que el estado **no cambió** |
| [134-157](src/test/resources/features/barista.feature#L134-L157) | Las 22 combinaciones inválidas de la matriz |

**Por qué es negativo:** se envía un evento que no corresponde al estado actual (por ejemplo, *Terminar Llenado*
estando *En Espera*) y se valida que el sistema lo **rechace**. La API responde HTTP 200, así que es negativo por
**regla de negocio**, no por código HTTP.

### 4. Feature Dron Agrícola (Ejercicio 2.3 - Tabla de Decisión)

Archivo: [`src/test/resources/features/dron.feature`](src/test/resources/features/dron.feature)

| Líneas | Qué hace |
|---|---|
| [7-15](src/test/resources/features/dron.feature#L7-L15) | Tabla de decisión: 3 condiciones (viento > 40 km/h, batería < 15 %, obstáculo < 2 m) y 4 reglas |
| [17-25](src/test/resources/features/dron.feature#L17-L25) | **Background**: define `basePath = 'decision/dron-agricola'` y reinicia el historial |
| [27-50](src/test/resources/features/dron.feature#L27-L50) | **R1** (#10): obstáculo → esquive de emergencia |
| [30](src/test/resources/features/dron.feature#L30) | Condiciones `[viento, bateria, true]`, el obstáculo siempre en `true` |
| [32-37](src/test/resources/features/dron.feature#L32-L37) | `POST evaluar` y valida la acción y `reglaIndex: 0` |
| [39-43](src/test/resources/features/dron.feature#L39-L43) | `GET definicion`: verifica que la evaluación quedó en el historial |
| [45-50](src/test/resources/features/dron.feature#L45-L50) | 4 combinaciones de viento y batería: el obstáculo siempre tiene prioridad |
| [52-73](src/test/resources/features/dron.feature#L52-L73) | **R2/R3** (#11): viento fuerte o batería baja sin obstáculo → RTL |
| [75-90](src/test/resources/features/dron.feature#L75-L90) | **R4** (#12): sin riesgos → continuar ruta |

**Todos son positivos:** toda combinación de condiciones tiene una regla definida. Entre todos cubren las
8 combinaciones posibles (2³).

### 5. Actor, habilidades, tareas y preguntas

El proyecto no implementa Screenplay con clases Java (eso es propio de Serenity BDD). Usa Karate, pero separa las
responsabilidades de forma equivalente:

| Concepto | Dónde | Explicación |
|---|---|---|
| **Actor** | [barista.feature:3](src/test/resources/features/barista.feature#L3) | El operador de la cafetería |
| **Habilidad** (consumir la API) | [karate-config.js:3](src/test/resources/karate-config.js#L3) y [barista.feature:11](src/test/resources/features/barista.feature#L11) | `baseUrl` y `url baseUrl`; Karate ya incluye el cliente HTTP |
| **Tarea** (enviar un evento) | [helpers/evento.feature:5-11](src/test/resources/features/helpers/evento.feature#L5-L11) | `POST slug/evento` y valida `valida == true` |
| **Tarea compuesta** | [barista.feature:14](src/test/resources/features/barista.feature#L14) | `moveTo` llama a `evento.feature` por cada evento de la lista |
| **Pregunta** (estado actual) | [helpers/estado.feature:6-10](src/test/resources/features/helpers/estado.feature#L6-L10) y [barista.feature:15](src/test/resources/features/barista.feature#L15) | `GET slug/estado`, envuelto en `getState()` |
| **Uso en un escenario** | [barista.feature:41-42](src/test/resources/features/barista.feature#L41-L42) | T2: ejecuta `moveTo(['Iniciar Pedido'])` y pregunta `getState()` |
| **Aserción** | [barista.feature:47-48](src/test/resources/features/barista.feature#L47-L48) | `match response contains {...}` y `match getState() == '...'` |
| `@ignore` | [evento.feature:1](src/test/resources/features/helpers/evento.feature#L1), [estado.feature:1](src/test/resources/features/helpers/estado.feature#L1) | Evita que el Runner ejecute los helpers como pruebas |

### 6. Cómo se implementó

| Archivo | Líneas | Qué hace |
|---|---|---|
| [build.gradle](build.gradle) | [13](build.gradle#L13), [16-20](build.gradle#L16-L20) | Versión de Karate (1.4.1) y dependencias (karate-junit5, logback) |
| [Runner.java](src/test/java/runner/Runner.java) | [13](src/test/java/runner/Runner.java#L13) | Ejecuta todo `classpath:features` |
| | [16](src/test/java/runner/Runner.java#L16) | `parallel(1)`: un escenario a la vez, porque la API tiene un único estado compartido |
| | [18](src/test/java/runner/Runner.java#L18) | La prueba JUnit falla si algún escenario falla |
| [karate-config.js](src/test/resources/karate-config.js) | [6-7](src/test/resources/karate-config.js#L6-L7) | Timeouts (60 s de lectura) porque Render duerme el servicio |
| [ci.yml](.github/workflows/ci.yml) | [3-13](.github/workflows/ci.yml#L3-L13) | Se ejecuta en push / pull request y de forma manual (`workflow_dispatch`) |
| | [54-59](.github/workflows/ci.yml#L54-L59) | En push corre `@smoke`; en ejecución manual, el tag indicado |
| | [114-127](.github/workflows/ci.yml#L114-L127) | Extrae el número de issue del tag (`@Issue-9` → 9) |
| | [140-177](.github/workflows/ci.yml#L140-L177) | Quita el label `status:*` anterior y pone `status:passed` o `status:failed` |
| | [179-195](.github/workflows/ci.yml#L179-L195) | Comenta el resultado en el issue con el enlace a la ejecución |
