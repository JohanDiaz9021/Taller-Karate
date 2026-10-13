@api @tablaDecision @dronAgricola
Feature: Sistema de Navegación de un Dron Agrícola Autónomo - Tabla de Decisión
  Como operador agrícola
  Quiero que el dron decida su maniobra según las condiciones del entorno
  Para proteger el equipo y el cultivo durante la misión

  # Condiciones: C1 Viento > 40 km/h | C2 Batería < 15% | C3 Obstáculo a menos de 2m
  #
  # | Condición      | R1 | R2 | R3 | R4 |
  # | C1 Viento      | -  | T  | F  | F  |
  # | C2 Batería     | -  | -  | T  | F  |
  # | C3 Obstáculo   | T  | F  | F  | F  |
  # | Acción         | Esquive | RTL | RTL | Continuar ruta |
  #
  # R1 tiene prioridad: con obstáculo cercano siempre se ejecuta el esquive.

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * def basePath = 'decision/dron-agricola'
    # Limpiar el historial de evaluaciones
    Given path basePath, 'reiniciar'
    When method post
    Then status 200
    And match response == { ok: true }

  @regression @Issue-10
  Scenario Outline: R1 - Obstáculo a menos de 2m ejecuta maniobra de esquive (viento=<viento>, bateria=<bateria>)
    # Given que el dron detecta viento=<viento>, batería baja=<bateria> y un obstáculo a menos de 2m
    * def valores = [<viento>, <bateria>, true]
    # When el sistema de navegación evalúa las condiciones
    Given path basePath, 'evaluar'
    And request { valores: '#(valores)' }
    When method post
    Then status 200
    # Then el dron ejecuta la maniobra de esquive de emergencia
    And match response == { valores: '#(valores)', accion: 'Ejecutar maniobra de esquive de emergencia', reglaIndex: 0, noDefinida: false }
    # And la evaluación queda registrada en el historial
    Given path basePath, 'definicion'
    When method get
    Then status 200
    And match response.historial == '#[1]'
    And match response.historial[0].accion == 'Ejecutar maniobra de esquive de emergencia'

    Examples:
      | viento | bateria |
      | false  | false   |
      | true   | false   |
      | false  | true    |
      | true   | true    |

  @regression @Issue-11
  Scenario Outline: R2/R3 - Viento fuerte o batería baja sin obstáculo aborta la misión con RTL (regla <regla>)
    # Given que el dron detecta viento=<viento>, batería baja=<bateria> y ningún obstáculo cercano
    * def valores = [<viento>, <bateria>, false]
    # When el sistema de navegación evalúa las condiciones
    Given path basePath, 'evaluar'
    And request { valores: '#(valores)' }
    When method post
    Then status 200
    # Then el dron aborta la misión y activa el retorno automático
    And match response == { valores: '#(valores)', accion: 'Abortar misión y activar retorno automático (RTL)', reglaIndex: <reglaIndex>, noDefinida: false }
    Given path basePath, 'definicion'
    When method get
    Then status 200
    And match response.historial == '#[1]'
    And match response.historial[0].accion == 'Abortar misión y activar retorno automático (RTL)'

    Examples:
      | regla | viento | bateria | reglaIndex |
      | R2    | true   | false   | 1          |
      | R3    | false  | true    | 2          |
      | R2    | true   | true    | 1          |

  @smoke @Issue-12
  Scenario: R4 - Sin condiciones de riesgo el dron continúa su ruta planificada
    # Given que el dron no detecta viento fuerte, ni batería baja, ni obstáculos
    * def valores = [false, false, false]
    # When el sistema de navegación evalúa las condiciones
    Given path basePath, 'evaluar'
    And request { valores: '#(valores)' }
    When method post
    Then status 200
    # Then el dron continúa su ruta de vuelo planificada
    And match response == { valores: '#(valores)', accion: 'Continuar ruta de vuelo planificada', reglaIndex: 3, noDefinida: false }
    Given path basePath, 'definicion'
    When method get
    Then status 200
    And match response.historial == '#[1]'
    And match response.historial[0].accion == 'Continuar ruta de vuelo planificada'
