# NOTA: el ejercicio 'encendido-apagado' NO existe en el API del taller
# (GET /api/encendido-apagado/estado -> 404 "Ejercicio no encontrado").
# Se conserva como referencia de la guía y se excluye con @ignore.
# Para activarlo, cambiar el path por un slug existente (ver GET /api/ejercicios).
@api @moduloInterruptor @ignore
Feature: Evaluación de Estado del Sistema de Interruptor

  @smoke @GH-1
  Scenario: Consultar estado actual del interruptor
    Given url baseUrl
    And path 'encendido-apagado/estado'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response.estado == '#present'
    And assert responseStatus == 200 || responseStatus == 409

  @regression @GH-2
  Scenario: Encender interruptor enviando payload JSON
    Given url baseUrl
    And path 'encendido-apagado/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'encender' }
    When method post
    Then status 200
    And match response.mensaje == '#string'
    And match response.estado == 'encendido'

  @smoke @GH-3
  Scenario: Reiniciar el estado del sistema
    Given url baseUrl
    And path 'encendido-apagado/reiniciar'
    And header Accept = 'application/json'
    When method post
    Then status 200
    And match response.mensaje == 'Sistema reiniciado exitosamente'
