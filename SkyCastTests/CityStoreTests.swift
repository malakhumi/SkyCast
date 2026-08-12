//  CityStoreTests.swift
//  SkyCastTests

import Testing
import Foundation
@testable import SkyCast

struct CityStoreTests {
    // MARK: Saved

        @Test func startsEmpty() {
            let store = makeStore()
            #expect(store.cities(in: .saved).isEmpty)
            #expect(store.cities(in: .recent).isEmpty)
        }

        @Test func savesACity() {
            let store = makeStore()
            store.add(.stub(name: "London"), to: .saved)

            #expect(store.cities(in: .saved).map(\.name) == ["London"])
        }

        @Test func doesNotSaveTheSameCityTwice() {
            let store = makeStore()
            store.add(.stub(name: "London"), to: .saved)
            store.add(.stub(name: "London"), to: .saved)

            #expect(store.cities(in: .saved).count == 1)
        }

        @Test func savedCitiesKeepTheOrderTheyWereAdded() {
            let store = makeStore()
            store.add(.stub(name: "London"), to: .saved)
            store.add(.stub(name: "Cairo"), to: .saved)
            store.add(.stub(name: "Oslo"), to: .saved)

            #expect(store.cities(in: .saved).map(\.name) == ["London", "Cairo", "Oslo"])
        }

        // MARK: Recent

        @Test func recentCitiesAreNewestFirst() {
            let store = makeStore()
            store.add(.stub(name: "London"), to: .recent)
            store.add(.stub(name: "Cairo"), to: .recent)

            #expect(store.cities(in: .recent).map(\.name) == ["Cairo", "London"])
        }

        @Test func viewingACityAgainMovesItToTheFront() {
            let store = makeStore()
            store.add(.stub(name: "London"), to: .recent)
            store.add(.stub(name: "Cairo"), to: .recent)
            store.add(.stub(name: "London"), to: .recent)

            #expect(store.cities(in: .recent).map(\.name) == ["London", "Cairo"])
        }

        @Test func recentIsCappedAtTen() {
            let store = makeStore()
            for index in 1...15 {
                store.add(.stub(name: "City \(index)"), to: .recent)
            }

            let recent = store.cities(in: .recent)
            #expect(recent.count == 10)
            #expect(recent.first?.name == "City 15")
            #expect(recent.last?.name == "City 6")
        }

        // MARK: Removing

        @Test func removesACity() {
            let store = makeStore()
            store.add(.stub(name: "London"), to: .saved)
            store.add(.stub(name: "Cairo"), to: .saved)

            store.remove(.stub(name: "London"), from: .saved)

            #expect(store.cities(in: .saved).map(\.name) == ["Cairo"])
        }

        @Test func removingACityThatIsNotStoredChangesNothing() {
            let store = makeStore()
            store.add(.stub(name: "London"), to: .saved)

            store.remove(.stub(name: "Oslo"), from: .saved)

            #expect(store.cities(in: .saved).count == 1)
        }

        // MARK: The two lists are independent

        @Test func savingACityDoesNotAddItToRecent() {
            let store = makeStore()
            store.add(.stub(name: "London"), to: .saved)

            #expect(store.cities(in: .recent).isEmpty)
        }

        @Test func removingFromRecentLeavesTheSavedCopy() {
            let store = makeStore()
            store.add(.stub(name: "London"), to: .saved)
            store.add(.stub(name: "London"), to: .recent)

            store.remove(.stub(name: "London"), from: .recent)

            #expect(store.cities(in: .saved).count == 1)
            #expect(store.cities(in: .recent).isEmpty)
        }

        // MARK: Persistence

        @Test func citiesSurviveANewStoreInstance() {
            let defaults = Self.emptyDefaults()
            CityStore(defaults: defaults).add(.stub(name: "London"), to: .saved)

            let reopened = CityStore(defaults: defaults)

            #expect(reopened.cities(in: .saved).map(\.name) == ["London"])
        }

        // MARK: Helpers

        private func makeStore() -> CityStore {
            CityStore(defaults: Self.emptyDefaults())
        }

        /// A throwaway suite so tests never touch the real user's saved cities.
        private static func emptyDefaults() -> UserDefaults {
            UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        }
}
