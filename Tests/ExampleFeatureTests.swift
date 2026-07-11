// ExampleFeatureTests.swift
// Ejemplo de referencia de Swift Testing (el framework moderno, NO XCTest).
// Borralo cuando tengas tests reales. Patrón: un @Suite por tipo bajo prueba.

import Testing
// @testable import __APP_NAME__   ← descomentá con el nombre real de tu app

@Suite("Ejemplo — patrones de Swift Testing")
struct ExampleFeatureTests {

    @Test("Los strings vacíos se detectan bien")
    func emptyStringDetection() {
        let input = ""
        #expect(input.isEmpty)
    }

    @Test("Suma básica", arguments: [(1, 2, 3), (5, 5, 10), (-1, 1, 0)])
    func addition(a: Int, b: Int, expected: Int) {
        // Tests parametrizados: un caso por tupla, fallan individualmente.
        #expect(a + b == expected)
    }

    @Test("Los errores esperados se lanzan")
    func throwsExpectedError() {
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(Int.self, from: Data("no-json".utf8))
        }
    }

    @Test("Async/await funciona directo en tests")
    func asyncWork() async throws {
        let value = await computeSomething()
        #expect(value > 0)
        // #require desempaca o aborta el test:
        // let user = try #require(await session.currentUser)
    }

    private func computeSomething() async -> Int { 42 }
}
