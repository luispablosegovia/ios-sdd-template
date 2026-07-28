// ExampleFeatureTests.swift
// Ejemplo de referencia de Swift Testing (el framework moderno, NO XCTest).
// Borralo cuando tengas tests reales. Patrón: un @Suite por tipo bajo prueba.

import Testing

// @testable import __APP_NAME__   ← descomentá con el nombre real de tu app

struct ExampleFeatureTests {
    @Test
    func `empty strings are detected`() {
        let input = ""
        #expect(input.isEmpty)
    }

    @Test(arguments: [(1, 2, 3), (5, 5, 10), (-1, 1, 0)])
    func `basic addition`(leftValue: Int, rightValue: Int, expected: Int) {
        // Tests parametrizados: un caso por tupla, fallan individualmente.
        #expect(leftValue + rightValue == expected)
    }

    @Test
    func `expected errors are thrown`() {
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(Int.self, from: Data("no-json".utf8))
        }
    }

    @Test
    func `async await works directly in tests`() async {
        let value = await computeSomething()
        #expect(value > 0)
        // #require desempaca o aborta el test:
        // let user = try #require(await session.currentUser)
    }

    private func computeSomething() async -> Int {
        42
    }
}
