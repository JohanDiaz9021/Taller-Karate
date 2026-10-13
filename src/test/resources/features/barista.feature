@api @moduloBarista
Feature: Robot Cafetero Automatizado (Barista Bot) - Transición de Estados

  Background:
    Given url baseUrl
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    # Cada escenario parte del estado inicial 'En Espera'
    And path 'barista-bot/reiniciar'
    When method post
    Then status 200
    And match response == { estadoActual: 'En Espera' }

  @smoke @GH-4
  Scenario: Consultar estado inicial y definición de la máquina
    Given path 'barista-bot/estado'
    When method get
    Then status 200
    And match response.estadoActual == 'En Espera'
    And match response.historial == []
    And match response.maquina.nombre == 'Robot Cafetero Automatizado (Barista Bot)'
    And match response.maquina.estados contains only ['En Espera', 'Moliendo', 'Calentando Agua', 'Sirviendo', 'Error de Insumos']
    And match response.maquina.eventos contains 'Iniciar Pedido'

  @smoke @GH-5
  Scenario: Iniciar pedido desde En Espera pasa a Moliendo
    Given path 'barista-bot/evento'
    And request { evento: 'Iniciar Pedido', guardia: null }
    When method post
    Then status 200
    And match response ==
      """
      {
        estadoAnterior: 'En Espera',
        evento: 'Iniciar Pedido',
        guardia: null,
        estadoNuevo: 'Moliendo',
        valida: true,
        accion: null
      }
      """

  @regression @GH-6
  Scenario Outline: Transiciones válidas del flujo feliz - <evento>
    # Lleva la máquina hasta el estado previo al evento evaluado
    * def previos = <previos>
    * def disparar = function(ev){ return karate.call('classpath:features/helpers/evento.feature', { slug: 'barista-bot', evento: ev }) }
    * karate.forEach(previos, disparar)
    Given path 'barista-bot/evento'
    And request { evento: '<evento>', guardia: null }
    When method post
    Then status 200
    And match response.estadoAnterior == '<desde>'
    And match response.estadoNuevo == '<hacia>'
    And match response.valida == true

    Examples:
      | previos                                                     | desde           | evento               | hacia           |
      | []                                                          | En Espera       | Iniciar Pedido       | Moliendo        |
      | ['Iniciar Pedido']                                          | Moliendo        | Terminar Molienda    | Calentando Agua |
      | ['Iniciar Pedido', 'Terminar Molienda']                     | Calentando Agua | Alcanzar Temperatura | Sirviendo       |
      | ['Iniciar Pedido', 'Terminar Molienda', 'Alcanzar Temperatura'] | Sirviendo   | Terminar Llenado     | En Espera       |

  @regression @GH-7
  Scenario: Falta de ingredientes interrumpe el flujo y se recupera con recarga
    * call read('classpath:features/helpers/evento.feature') { slug: 'barista-bot', evento: 'Iniciar Pedido' }
    Given path 'barista-bot/evento'
    And request { evento: 'Sin Ingredientes', guardia: null }
    When method post
    Then status 200
    And match response.estadoNuevo == 'Error de Insumos'
    And match response.accion == 'Interrumpir flujo'

    Given path 'barista-bot/evento'
    And request { evento: 'Recargar y Reiniciar', guardia: null }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Error de Insumos'
    And match response.estadoNuevo == 'En Espera'
    And match response.accion == 'Restaurar servicio'

  @regression @GH-8
  Scenario: Evento no definido en el estado actual no cambia el estado
    Given path 'barista-bot/evento'
    And request { evento: 'Terminar Llenado', guardia: null }
    When method post
    Then status 200
    And match response.estadoAnterior == 'En Espera'
    And match response.estadoNuevo == 'En Espera'
    And match response.valida == false
    And match response.noDefinida == true

  @regression @GH-9
  Scenario: Evento desconocido es rechazado con 400
    Given path 'barista-bot/evento'
    And request { evento: 'Evento Falso', guardia: null }
    When method post
    Then status 400
    And match response.error == 'Evento desconocido: Evento Falso'

  @regression @GH-10
  Scenario: El historial registra las transiciones ejecutadas
    * call read('classpath:features/helpers/evento.feature') { slug: 'barista-bot', evento: 'Iniciar Pedido' }
    * call read('classpath:features/helpers/evento.feature') { slug: 'barista-bot', evento: 'Terminar Molienda' }
    Given path 'barista-bot/estado'
    When method get
    Then status 200
    And match response.estadoActual == 'Calentando Agua'
    And match response.historial == '#[2]'
    And match each response.historial == { estadoAnterior: '#string', evento: '#string', guardia: '##null', estadoNuevo: '#string', valida: '#boolean', accion: '##string' }
    And match response.historial[1].evento == 'Terminar Molienda'
