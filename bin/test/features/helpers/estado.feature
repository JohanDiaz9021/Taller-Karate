@ignore
Feature: Helper reutilizable - consulta el estado actual de una máquina de estados

  # Uso: * def result = call read('classpath:features/helpers/estado.feature') { slug: 'barista-bot' }
  #      result.response.estadoActual
  Scenario: Consultar estado
    Given url baseUrl
    And path slug, 'estado'
    When method get
    Then status 200
