//  Fixtures.swift
//  SkyCastTests

import Foundation
@testable import SkyCast

extension CurrentWeatherResponse {
    static func stub(
        name: String = "Testville",
        temp: Double = 20,
        icon: String = "01d"
    ) -> CurrentWeatherResponse {
        CurrentWeatherResponse(
            coord: Coordinates(lat: 51.5, lon: -0.12),
            weather: [
                WeatherCondition(id: 800, main: "Clear", description: "clear sky", icon: icon)
            ],
            main: WeatherMetrics(
                temp: temp,
                feelsLike: temp,
                tempMin: temp - 2,
                tempMax: temp + 2,
                humidity: 60
            ),
            wind: Wind(speed: 4, deg: 180, gust: nil),
            visibility: 10_000,
            dt: 1_754_000_000,
            sys: CurrentWeatherResponse.SystemInfo(country: "GB", sunrise: nil, sunset: nil),
            timezone: 0,
            name: name
        )
    }
}

extension ForecastResponse {
    /// Builds a forecast with `count` entries, three hours apart.
    static func stub(entryCount: Int = 40) -> ForecastResponse {
        let start = Date(timeIntervalSince1970: 1_754_000_000)

        let entries = (0..<entryCount).map { index in
            Entry(
                dt: Int(start.addingTimeInterval(TimeInterval(index) * 3 * 3600).timeIntervalSince1970),
                main: WeatherMetrics(
                    temp: 20,
                    feelsLike: 20,
                    tempMin: 18,
                    tempMax: 22,
                    humidity: 60
                ),
                weather: [
                    WeatherCondition(id: 800, main: "Clear", description: "clear sky", icon: "01d")
                ],
                wind: Wind(speed: 4, deg: 180, gust: nil),
                pop: 0.1
            )
        }

        return ForecastResponse(
            list: entries,
            city: City(name: "Testville", country: "GB", timezone: 0)
        )
    }
}

extension GeocodingResult {
    static func stub(name: String = "Testville") -> GeocodingResult {
        GeocodingResult(name: name, lat: 51.5, lon: -0.12, country: "GB", state: "England")
    }
}
