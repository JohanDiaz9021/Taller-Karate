# Test Cases - Automatización de Pruebas Backend con Karate

Repositorio: https://github.com/JohanDiaz9021/Taller-Karate
API: `https://taller-de-tecnicas-de-prueba-de-caja.onrender.com/api/`

| Bloque | Ejercicio seleccionado | Técnica | Feature |
|---|---|---|---|
| 1 | 1.2 Robot Cafetero Automatizado (Barista Bot) | Transición de Estados | `src/test/resources/features/barista.feature` |
| 2 | 2.3 Sistema de Navegación de un Dron Agrícola Autónomo | Tabla de Decisión | `src/test/resources/features/dron.feature` |

## Matriz de trazabilidad

| Caso | Descripción | Técnica | Issue | Tag Karate | Ejecuciones |
|---|---|---|---|---|---|
| T1 | En Espera → *Iniciar Pedido* → Moliendo | Transición válida | [#1](https://github.com/JohanDiaz9021/Taller-Karate/issues/1) | `@Issue-1` | 1 |
| T2 | Moliendo → *Terminar Molienda* → Calentando Agua | Transición válida | [#2](https://github.com/JohanDiaz9021/Taller-Karate/issues/2) | `@Issue-2` | 1 |
| T3 | Calentando Agua → *Alcanzar Temperatura* → Sirviendo | Transición válida | [#3](https://github.com/JohanDiaz9021/Taller-Karate/issues/3) | `@Issue-3` | 1 |
| T4 | Sirviendo → *Terminar Llenado* → En Espera | Transición válida | [#4](https://github.com/JohanDiaz9021/Taller-Karate/issues/4) | `@Issue-4` | 1 |
| T5 | Moliendo → *Sin Ingredientes* → Error de Insumos | Transición válida | [#5](https://github.com/JohanDiaz9021/Taller-Karate/issues/5) | `@Issue-5` | 1 |
| T6 | Calentando Agua → *Sin Ingredientes* → Error de Insumos | Transición válida | [#6](https://github.com/JohanDiaz9021/Taller-Karate/issues/6) | `@Issue-6` | 1 |
| T7 | Sirviendo → *Sin Ingredientes* → Error de Insumos | Transición válida | [#7](https://github.com/JohanDiaz9021/Taller-Karate/issues/7) | `@Issue-7` | 1 |
| T8 | Error de Insumos → *Recargar y Reiniciar* → En Espera | Transición válida | [#8](https://github.com/JohanDiaz9021/Taller-Karate/issues/8) | `@Issue-8` | 1 |
| TI | 22 transiciones inválidas no cambian el estado | Transición inválida (Outline) | [#9](https://github.com/JohanDiaz9021/Taller-Karate/issues/9) | `@Issue-9` | 22 |
| R1 | Obstáculo < 2m → esquive de emergencia | Tabla de decisión (Outline) | [#10](https://github.com/JohanDiaz9021/Taller-Karate/issues/10) | `@Issue-10` | 4 |
| R2/R3 | Viento fuerte o batería baja → RTL | Tabla de decisión (Outline) | [#11](https://github.com/JohanDiaz9021/Taller-Karate/issues/11) | `@Issue-11` | 3 |
| R4 | Sin condiciones de riesgo → continuar ruta | Tabla de decisión | [#12](https://github.com/JohanDiaz9021/Taller-Karate/issues/12) | `@Issue-12` | 1 |

**Total:** 12 escenarios / 12 issues / 38 ejecuciones.

---

## Bloque 1 - Barista Bot (Transición de Estados)

### Matriz de transición

Análisis de 30 intersecciones (5 estados × 6 eventos): **8 válidas, 22 inválidas**.

| Estado \ Evento | Iniciar Pedido | Terminar Molienda | Alcanzar Temperatura | Terminar Llenado | Sin Ingredientes | Recargar y Reiniciar |
|---|---|---|---|---|---|---|
| **S1 En Espera** | VÁLIDO → S2 | INVÁLIDO | INVÁLIDO | INVÁLIDO | INVÁLIDO | INVÁLIDO |
| **S2 Moliendo** | INVÁLIDO | VÁLIDO → S3 | INVÁLIDO | INVÁLIDO | VÁLIDO → S5 (Interrumpir flujo) | INVÁLIDO |
| **S3 Calentando Agua** | INVÁLIDO | INVÁLIDO | VÁLIDO → S4 | INVÁLIDO | VÁLIDO → S5 (Interrumpir flujo) | INVÁLIDO |
| **S4 Sirviendo** | INVÁLIDO | INVÁLIDO | INVÁLIDO | VÁLIDO → S1 | VÁLIDO → S5 (Interrumpir flujo) | INVÁLIDO |
| **S5 Error de Insumos** | INVÁLIDO | INVÁLIDO | INVÁLIDO | INVÁLIDO | INVÁLIDO | VÁLIDO → S1 (Restaurar servicio) |

### Especificación en Gherkin

```gherkin
Feature: Control del Robot Cafetero Automatizado (Barista Bot)
  Como operador de la cafetería
  Quiero controlar el ciclo de preparación del robot cafetero
  Para preparar pedidos de forma segura y recuperar el servicio ante fallas de insumos

  # Precondición común: antes de cada escenario se reinicia el robot al estado S1 (En Espera)
  # y se ejecutan los eventos necesarios hasta llegar al estado inicial del caso.

  # Escenarios positivos (transiciones válidas)

  @Issue-1
  Scenario: T1 - Iniciar pedido desde En Espera
    Given que el robot está en el estado "En Espera"
    When el operador envía el evento "Iniciar Pedido"
    Then el robot pasa al estado "Moliendo"

  @Issue-2
  Scenario: T2 - Terminar la molienda
    * consultar el estado del robot
    * mover el robot hasta S1 y ejecutar "Iniciar Pedido"
    Given que el robot está en el estado "Moliendo"
    When el operador envía el evento "Terminar Molienda"
    Then el robot pasa al estado "Calentando Agua"

  @Issue-3
  Scenario: T3 - Alcanzar la temperatura del agua
    * mover el robot hasta S1 y ejecutar "Iniciar Pedido", "Terminar Molienda"
    Given que el robot está en el estado "Calentando Agua"
    When el operador envía el evento "Alcanzar Temperatura"
    Then el robot pasa al estado "Sirviendo"

  @Issue-4
  Scenario: T4 - Terminar el llenado de la taza
    * mover el robot hasta S1 y ejecutar "Iniciar Pedido", "Terminar Molienda", "Alcanzar Temperatura"
    Given que el robot está en el estado "Sirviendo"
    When el operador envía el evento "Terminar Llenado"
    Then el robot pasa al estado "En Espera"

  @Issue-5
  Scenario: T5 - Falta de ingredientes durante la molienda
    * mover el robot hasta S1 y ejecutar "Iniciar Pedido"
    Given que el robot está en el estado "Moliendo"
    When el operador envía el evento "Sin Ingredientes"
    Then el robot pasa al estado "Error de Insumos"
    And ejecuta la acción "Interrumpir flujo"

  @Issue-6
  Scenario: T6 - Falta de ingredientes durante el calentamiento
    * mover el robot hasta S1 y ejecutar "Iniciar Pedido", "Terminar Molienda"
    Given que el robot está en el estado "Calentando Agua"
    When el operador envía el evento "Sin Ingredientes"
    Then el robot pasa al estado "Error de Insumos"
    And ejecuta la acción "Interrumpir flujo"

  @Issue-7
  Scenario: T7 - Falta de ingredientes durante el servido
    * mover el robot hasta S1 y ejecutar "Iniciar Pedido", "Terminar Molienda", "Alcanzar Temperatura"
    Given que el robot está en el estado "Sirviendo"
    When el operador envía el evento "Sin Ingredientes"
    Then el robot pasa al estado "Error de Insumos"
    And ejecuta la acción "Interrumpir flujo"

  @Issue-8
  Scenario: T8 - Recargar insumos y reiniciar el servicio
    * mover el robot hasta S1 y ejecutar "Iniciar Pedido", "Sin Ingredientes"
    Given que el robot está en el estado "Error de Insumos"
    When el operador envía el evento "Recargar y Reiniciar"
    Then el robot pasa al estado "En Espera"
    And ejecuta la acción "Restaurar servicio"

  # Escenario negativo (transiciones inválidas)

  @Issue-9
  Scenario Outline: Bloquear transiciones no permitidas en el robot cafetero
    * consultar el estado del robot
    * mover el robot hasta S1 y ejecutar los eventos de "<camino>"
    Given que el robot se encuentra en el estado "<estado_actual>"
    When el operador intenta enviar el evento "<evento>"
    Then el robot no debe cambiar de estado
    And debe marcar la transición como inválida (no definida)

    Examples:
      | estado_actual    | camino                                                 | evento               |
      | En Espera        | -                                                      | Terminar Molienda    |
      | En Espera        | -                                                      | Alcanzar Temperatura |
      | En Espera        | -                                                      | Terminar Llenado     |
      | En Espera        | -                                                      | Sin Ingredientes     |
      | En Espera        | -                                                      | Recargar y Reiniciar |
      | Moliendo         | Iniciar Pedido                                         | Iniciar Pedido       |
      | Moliendo         | Iniciar Pedido                                         | Alcanzar Temperatura |
      | Moliendo         | Iniciar Pedido                                         | Terminar Llenado     |
      | Moliendo         | Iniciar Pedido                                         | Recargar y Reiniciar |
      | Calentando Agua  | Iniciar Pedido, Terminar Molienda                      | Iniciar Pedido       |
      | Calentando Agua  | Iniciar Pedido, Terminar Molienda                      | Terminar Molienda    |
      | Calentando Agua  | Iniciar Pedido, Terminar Molienda                      | Terminar Llenado     |
      | Calentando Agua  | Iniciar Pedido, Terminar Molienda                      | Recargar y Reiniciar |
      | Sirviendo        | Iniciar Pedido, Terminar Molienda, Alcanzar Temperatura | Iniciar Pedido       |
      | Sirviendo        | Iniciar Pedido, Terminar Molienda, Alcanzar Temperatura | Terminar Molienda    |
      | Sirviendo        | Iniciar Pedido, Terminar Molienda, Alcanzar Temperatura | Alcanzar Temperatura |
      | Sirviendo        | Iniciar Pedido, Terminar Molienda, Alcanzar Temperatura | Recargar y Reiniciar |
      | Error de Insumos | Iniciar Pedido, Sin Ingredientes                       | Iniciar Pedido       |
      | Error de Insumos | Iniciar Pedido, Sin Ingredientes                       | Terminar Molienda    |
      | Error de Insumos | Iniciar Pedido, Sin Ingredientes                       | Alcanzar Temperatura |
      | Error de Insumos | Iniciar Pedido, Sin Ingredientes                       | Terminar Llenado     |
      | Error de Insumos | Iniciar Pedido, Sin Ingredientes                       | Sin Ingredientes     |
```

---

## Bloque 2 - Dron Agrícola (Tabla de Decisión)

### Tabla de decisión

| Condiciones / Reglas | R1 | R2 | R3 | R4 |
|---|---|---|---|---|
| C1: ¿Viento > 40 km/h? | – | T | F | F |
| C2: ¿Batería < 15%? | – | – | T | F |
| C3: ¿Obstáculo a menos de 2m? | T | F | F | F |
| **Acciones** | | | | |
| Ejecutar maniobra de esquive de emergencia | X | | | |
| Abortar misión y activar retorno automático (RTL) | | X | X | |
| Continuar ruta de vuelo planificada | | | | X |

**Análisis:**
- **R1 (prioridad máxima):** si hay un obstáculo a menos de 2m, el dron esquiva sin importar el viento o la batería. Se valida con las 4 combinaciones de C1/C2 con C3 = T.
- **R2 y R3:** comparten la acción RTL, por eso se agrupan en un solo Scenario Outline (igual que el ejemplo de envío gratis). Se incluye además la combinación `[T,T,F]`, que el sistema resuelve con R2.
- **R4 (caso por defecto):** sin ninguna condición de riesgo, el dron continúa su ruta.

Con estos casos se cubren las 8 combinaciones posibles de las 3 condiciones.

### Especificación en Gherkin

```gherkin
Feature: Navegación autónoma del Dron Agrícola
  Como operador agrícola
  Quiero que el dron decida su maniobra según las condiciones del entorno
  Para proteger el equipo y el cultivo durante la misión

  @Issue-10
  Scenario Outline: R1 - Esquive de emergencia ante obstáculo cercano
    Given que el dron detecta viento fuerte "<viento>" y batería baja "<bateria>"
    And detecta un obstáculo a menos de 2m
    When el sistema de navegación evalúa las condiciones
    Then el dron debe ejecutar la maniobra de esquive de emergencia

    Examples:
      | viento | bateria |
      | No     | No      |
      | Sí     | No      |
      | No     | Sí      |
      | Sí     | Sí      |

  @Issue-11
  Scenario Outline: R2/R3 - Abortar misión con retorno automático
    Given que el dron detecta viento fuerte "<viento>" y batería baja "<bateria>"
    And no detecta obstáculos cercanos
    When el sistema de navegación evalúa las condiciones
    Then el dron debe abortar la misión y activar el retorno automático (RTL)

    Examples:
      | regla | viento | bateria |
      | R2    | Sí     | No      |
      | R3    | No     | Sí      |
      | R2    | Sí     | Sí      |

  @Issue-12
  Scenario: R4 - Continuar ruta en condiciones normales
    Given que el dron no detecta viento fuerte
    And la batería está por encima del 15%
    And no detecta obstáculos cercanos
    When el sistema de navegación evalúa las condiciones
    Then el dron debe continuar su ruta de vuelo planificada
```
