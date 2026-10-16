@ignore
Feature: Helper reutilizable - dispara un evento sobre una máquina de estados

  # Uso: * call read('classpath:features/helpers/evento.feature') { slug: 'barista-bot', evento: 'Iniciar Pedido' }
  Scenario: Disparar evento
    Given url baseUrl
    And path slug, 'evento'
    And request { evento: '#(evento)' }
    When method post
    Then status 200
    And match response.valida == true
