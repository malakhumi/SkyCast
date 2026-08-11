//  AppSettings.swift
//  SkyCast

import Foundation
import Observation

@Observable
final class AppSettings {
    
    var temperatureUnit: TemperatureUnit {
        didSet { defaults.set(temperatureUnit.rawValue, forKey: Keys.temperature) }
    }
    
    var windSpeedUnit: WindSpeedUnit {
        didSet { defaults.set(windSpeedUnit.rawValue, forKey: Keys.windSpeed) }
    }
    
    private enum Keys {
        static let temperature = "temperatureUnit"
        static let windSpeed = "windSpeedUnit"
    }
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.temperatureUnit = TemperatureUnit(
            rawValue: defaults.string(forKey: Keys.temperature) ?? ""
        ) ?? .celsius
        self.windSpeedUnit = WindSpeedUnit(
            rawValue: defaults.string(forKey: Keys.windSpeed) ?? ""
        ) ?? .metersPerSecond
    }
}

extension AppSettings {

    func temperatureValue(_ celsius: Double) -> String {
        "\(Int(temperatureUnit.convert(fromCelsius: celsius).rounded()))"
    }

    /// "26°"
    func temperature(_ celsius: Double) -> String {
        temperatureValue(celsius) + "°"
    }

    /// "6.4 m/s"
    func wind(_ metersPerSecond: Double) -> String {
        String(
            format: "%.1f %@",
            windSpeedUnit.convert(fromMetersPerSecond: metersPerSecond),
            windSpeedUnit.symbol
        )
    }
}

extension AppSettings {
    var temperatureSymbol: String { temperatureUnit.symbol }
}
