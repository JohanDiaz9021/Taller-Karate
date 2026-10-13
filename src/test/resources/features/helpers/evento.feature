@ignore
Feature: Helper reutilizable - dispara un evento sobre un ejercicio

  # Uso: * call read('classpath:features/helpers/evento.feature') { slug: 'barista-bot', evento: 'Iniciar Pedido' }
  Scenario: Disparar evento
    Given url baseUrl
    And path slug, 'evento'
    And header Content-Type = 'application/json'
    And request { evento: '#(evento)', guardia: null }
    When method post
    Then status 200
