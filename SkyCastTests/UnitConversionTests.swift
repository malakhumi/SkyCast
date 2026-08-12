//  UnitConversionTests.swift
//  SkyCastTests

import Testing
import Foundation
@testable import SkyCast

struct UnitConversionTests {

    // MARK: Temperature

    @Test func celsiusIsUnchanged() {
        #expect(TemperatureUnit.celsius.convert(fromCelsius: 21.5) == 21.5)
    }

    @Test func convertsCelsiusToFahrenheit() {
        #expect(TemperatureUnit.fahrenheit.convert(fromCelsius: 0) == 32)
        #expect(TemperatureUnit.fahrenheit.convert(fromCelsius: 100) == 212)
        #expect(TemperatureUnit.fahrenheit.convert(fromCelsius: -40) == -40)
    }

    // MARK: Wind speed

    @Test func metresPerSecondIsUnchanged() {
        #expect(WindSpeedUnit.metersPerSecond.convert(fromMetersPerSecond: 4.2) == 4.2)
    }

    @Test func convertsMetresPerSecondToKilometresPerHour() {
        #expect(WindSpeedUnit.kilometresPerHour.convert(fromMetersPerSecond: 10) == 36)
    }

    // MARK: Formatting

    @Test func formatsTemperatureInTheChosenUnit() {
        let settings = AppSettings(defaults: Self.emptyDefaults())

        settings.temperatureUnit = .celsius
        #expect(settings.temperature(26.4) == "26°")

        settings.temperatureUnit = .fahrenheit
        #expect(settings.temperature(26.4) == "80°")
    }

    @Test func formatsWindInTheChosenUnit() {
        let settings = AppSettings(defaults: Self.emptyDefaults())

        settings.windSpeedUnit = .metersPerSecond
        #expect(settings.wind(6.44) == "6.4 m/s")

        settings.windSpeedUnit = .kilometresPerHour
        #expect(settings.wind(10) == "36.0 km/h")
    }

    @Test func defaultsToCelsiusAndMetresPerSecond() {
        let settings = AppSettings(defaults: Self.emptyDefaults())
        #expect(settings.temperatureUnit == .celsius)
        #expect(settings.windSpeedUnit == .metersPerSecond)
    }

    /// A throwaway suite so tests never touch the real user's preferences.
    private static func emptyDefaults() -> UserDefaults {
        UserDefaults(suiteName: "test-\(UUID().uuidString)")!
    }
}
