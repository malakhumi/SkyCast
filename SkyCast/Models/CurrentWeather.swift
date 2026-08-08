//  CurrentWeather.swift
//  SkyCast


import Foundation
/// Decoded response from OpenWeather's current weather endpoint (`/data/2.5/weather`).
struct CurrentWeatherResponse: Codable {
    let coord: Coordinates
    let weather: [WeatherCondition]
    let main: WeatherMetrics
    let wind: Wind
    let visibility: Int?
    let dt: Int
    let sys: SystemInfo
    let timezone: Int
    let name: String

    struct SystemInfo: Codable {
        let country: String?
        let sunrise: Int?
        let sunset: Int?
    }
}

extension CurrentWeatherResponse {
    var condition: WeatherCondition? { weather.first }
    var measuredAt: Date { Date(timeIntervalSince1970: TimeInterval(dt)) }
    /// OpenWeather's icon code ends in "n" at night, "d" during the day.
    /// This reflects the city's local time, not the device's.
    var isNight: Bool {
        condition?.icon.hasSuffix("n") ?? true
    }
}
