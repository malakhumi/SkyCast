//  Units.swift
//  SkyCast

import Foundation

enum TemperatureUnit: String, CaseIterable, Identifiable {
    case celsius
    case fahrenheit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .celsius: return "Celsius"
        case .fahrenheit: return "Fahrenheit"
        }
    }

    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }

    /// The API always returns Celsius, so conversion happens at display time.
    func convert(fromCelsius value: Double) -> Double {
        switch self {
        case .celsius: return value
        case .fahrenheit: return value * 9 / 5 + 32
        }
    }
}

enum WindSpeedUnit: String, CaseIterable, Identifiable {
    case metersPerSecond
    case kilometresPerHour

    var id: String { rawValue }

    var title: String {
        switch self {
        case .metersPerSecond: return "Metres per second"
        case .kilometresPerHour: return "Kilometres per hour"
        }
    }

    var symbol: String {
        switch self {
        case .metersPerSecond: return "m/s"
        case .kilometresPerHour: return "km/h"
        }
    }

    func convert(fromMetersPerSecond value: Double) -> Double {
        switch self {
        case .metersPerSecond: return value
        case .kilometresPerHour: return value * 3.6
        }
    }
}
