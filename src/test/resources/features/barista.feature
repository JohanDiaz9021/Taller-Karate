@api @transicionEstados @baristaBot
Feature: Robot Cafetero Automatizado (Barista Bot) - Transición de Estados
  Como operador de la cafetería
  Quiero controlar el ciclo de preparación del robot cafetero
  Para preparar pedidos de forma segura y recuperar el servicio ante fallas de insumos

  # Matriz: 5 estados x 6 eventos = 30 combinaciones -> 8 transiciones válidas y 22 inválidas.
  # Cada escenario parte de S1 (En Espera) y recorre el camino necesario hasta su estado inicial.

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * def slug = 'barista-bot'
    * def moveTo = function(events){ for (var i = 0; i < events.length; i++) karate.call('classpath:features/helpers/evento.feature', { slug: slug, evento: events[i] }) }
    * def getState = function(){ return karate.call('classpath:features/helpers/estado.feature', { slug: slug }).response.estadoActual }
    # Llevar la máquina al estado inicial S1
    Given path slug, 'reiniciar'
    When method post
    Then status 200
    And match response.estadoActual == 'En Espera'

  # ---------------------------------------------------------------------------
  # Escenarios positivos: transiciones válidas
  # ---------------------------------------------------------------------------

  @smoke @Issue-1
  Scenario: T1 - Iniciar pedido desde En Espera pasa a Moliendo
    # Given que el robot está en el estado "En Espera"
    * match getState() == 'En Espera'
    # When el operador envía el evento "Iniciar Pedido"
    Given path slug, 'evento'
    And request { evento: 'Iniciar Pedido' }
    When method post
    Then status 200
    # Then el robot pasa al estado "Moliendo"
    And match response contains { estadoAnterior: 'En Espera', evento: 'Iniciar Pedido', estadoNuevo: 'Moliendo', valida: true, accion: null }
    And match getState() == 'Moliendo'

  @regression @Issue-2
  Scenario: T2 - Terminar molienda pasa a Calentando Agua
    * moveTo(['Iniciar Pedido'])
    * match getState() == 'Moliendo'
    Given path slug, 'evento'
    And request { evento: 'Terminar Molienda' }
    When method post
    Then status 200
    And match response contains { estadoAnterior: 'Moliendo', evento: 'Terminar Molienda', estadoNuevo: 'Calentando Agua', valida: true, accion: null }
    And match getState() == 'Calentando Agua'

  @regression @Issue-3
  Scenario: T3 - Alcanzar temperatura pasa a Sirviendo
    * moveTo(['Iniciar Pedido', 'Terminar Molienda'])
    * match getState() == 'Calentando Agua'
    Given path slug, 'evento'
    And request { evento: 'Alcanzar Temperatura' }
    When method post
    Then status 200
    And match response contains { estadoAnterior: 'Calentando Agua', evento: 'Alcanzar Temperatura', estadoNuevo: 'Sirviendo', valida: true, accion: null }
    And match getState() == 'Sirviendo'

  @regression @Issue-4
  Scenario: T4 - Terminar llenado regresa a En Espera
    * moveTo(['Iniciar Pedido', 'Terminar Molienda', 'Alcanzar Temperatura'])
    * match getState() == 'Sirviendo'
    Given path slug, 'evento'
    And request { evento: 'Terminar Llenado' }
    When method post
    Then status 200
    And match response contains { estadoAnterior: 'Sirviendo', evento: 'Terminar Llenado', estadoNuevo: 'En Espera', valida: true, accion: null }
    And match getState() == 'En Espera'

  @regression @Issue-5
  Scenario: T5 - Falta de ingredientes durante la molienda interrumpe el flujo
    * moveTo(['Iniciar Pedido'])
    * match getState() == 'Moliendo'
    Given path slug, 'evento'
    And request { evento: 'Sin Ingredientes' }
    When method post
    Then status 200
    And match response contains { estadoAnterior: 'Moliendo', evento: 'Sin Ingredientes', estadoNuevo: 'Error de Insumos', valida: true, accion: 'Interrumpir flujo' }
    And match getState() == 'Error de Insumos'

  @regression @Issue-6
  Scenario: T6 - Falta de ingredientes durante el calentamiento interrumpe el flujo
    * moveTo(['Iniciar Pedido', 'Terminar Molienda'])
    * match getState() == 'Calentando Agua'
    Given path slug, 'evento'
    And request { evento: 'Sin Ingredientes' }
    When method post
    Then status 200
    And match response contains { estadoAnterior: 'Calentando Agua', evento: 'Sin Ingredientes', estadoNuevo: 'Error de Insumos', valida: true, accion: 'Interrumpir flujo' }
    And match getState() == 'Error de Insumos'

  @regression @Issue-7
  Scenario: T7 - Falta de ingredientes durante el servido interrumpe el flujo
    * moveTo(['Iniciar Pedido', 'Terminar Molienda', 'Alcanzar Temperatura'])
    * match getState() == 'Sirviendo'
    Given path slug, 'evento'
    And request { evento: 'Sin Ingredientes' }
    When method post
    Then status 200
    And match response contains { estadoAnterior: 'Sirviendo', evento: 'Sin Ingredientes', estadoNuevo: 'Error de Insumos', valida: true, accion: 'Interrumpir flujo' }
    And match getState() == 'Error de Insumos'

  @smoke @Issue-8
  Scenario: T8 - Recargar y reiniciar restaura el servicio desde Error de Insumos
    * moveTo(['Iniciar Pedido', 'Sin Ingredientes'])
    * match getState() == 'Error de Insumos'
    Given path slug, 'evento'
    And request { evento: 'Recargar y Reiniciar' }
    When method post
    Then status 200
    And match response contains { estadoAnterior: 'Error de Insumos', evento: 'Recargar y Reiniciar', estadoNuevo: 'En Espera', valida: true, accion: 'Restaurar servicio' }
    And match getState() == 'En Espera'

  # ---------------------------------------------------------------------------
  # Escenario negativo: transiciones inválidas (22 combinaciones no definidas)
  # ---------------------------------------------------------------------------

  @regression @Issue-9
  Scenario Outline: Transición inválida - <estado_actual> + <evento> no cambia el estado
    # Given que el robot se encuentra en el estado "<estado_actual>"
    * moveTo(<camino>)
    * match getState() == '<estado_actual>'
    # When el operador intenta enviar el evento "<evento>"
    Given path slug, 'evento'
    And request { evento: '<evento>' }
    When method post
    Then status 200
    # Then el robot no cambia de estado y marca la transición como no definida
    And match response contains { estadoAnterior: '<estado_actual>', evento: '<evento>', estadoNuevo: '<estado_actual>', valida: false, noDefinida: true }
    And match getState() == '<estado_actual>'

    Examples:
      | estado_actual    | camino                                                          | evento               |
      | En Espera        | []                                                              | Terminar Molienda    |
      | En Espera        | []                                                              | Alcanzar Temperatura |
      | En Espera        | []                                                              | Terminar Llenado     |
      | En Espera        | []                                                              | Sin Ingredientes     |
      | En Espera        | []                                                              | Recargar y Reiniciar |
      | Moliendo         | ['Iniciar Pedido']                                              | Iniciar Pedido       |
      | Moliendo         | ['Iniciar Pedido']                                              | Alcanzar Temperatura |
      | Moliendo         | ['Iniciar Pedido']                                              | Terminar Llenado     |
      | Moliendo         | ['Iniciar Pedido']                                              | Recargar y Reiniciar |
      | Calentando Agua  | ['Iniciar Pedido', 'Terminar Molienda']                         | Iniciar Pedido       |
      | Calentando Agua  | ['Iniciar Pedido', 'Terminar Molienda']                         | Terminar Molienda    |
      | Calentando Agua  | ['Iniciar Pedido', 'Terminar Molienda']                         | Terminar Llenado     |
      | Calentando Agua  | ['Iniciar Pedido', 'Terminar Molienda']                         | Recargar y Reiniciar |
      | Sirviendo        | ['Iniciar Pedido', 'Terminar Molienda', 'Alcanzar Temperatura'] | Iniciar Pedido       |
      | Sirviendo        | ['Iniciar Pedido', 'Terminar Molienda', 'Alcanzar Temperatura'] | Terminar Molienda    |
      | Sirviendo        | ['Iniciar Pedido', 'Terminar Molienda', 'Alcanzar Temperatura'] | Alcanzar Temperatura |
      | Sirviendo        | ['Iniciar Pedido', 'Terminar Molienda', 'Alcanzar Temperatura'] | Recargar y Reiniciar |
      | Error de Insumos | ['Iniciar Pedido', 'Sin Ingredientes']                          | Iniciar Pedido       |
      | Error de Insumos | ['Iniciar Pedido', 'Sin Ingredientes']                          | Terminar Molienda    |
      | Error de Insumos | ['Iniciar Pedido', 'Sin Ingredientes']                          | Alcanzar Temperatura |
      | Error de Insumos | ['Iniciar Pedido', 'Sin Ingredientes']                          | Terminar Llenado     |
      | Error de Insumos | ['Iniciar Pedido', 'Sin Ingredientes']                          | Sin Ingredientes     |
