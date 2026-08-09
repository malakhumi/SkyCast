//  Forecast.swift
//  SkyCast

import Foundation

/// Decoded response from `/data/2.5/forecast` —
/// 40 entries at three-hour steps, covering five days.
struct ForecastResponse: Codable {
    let list: [Entry]
    let city: City

    struct Entry: Codable, Identifiable {
        let dt: Int
        let main: WeatherMetrics
        let weather: [WeatherCondition]
        let wind: Wind
        /// Probability of precipitation, 0...1.
        let pop: Double?

        var id: Int { dt }
        var date: Date { Date(timeIntervalSince1970: TimeInterval(dt)) }
        var condition: WeatherCondition? { weather.first }
    }

    struct City: Codable {
        let name: String
        let country: String
        let timezone: Int
    }
}


struct DailyForecast: Identifiable, Hashable {
    let date: Date
    let minTemp: Double
    let maxTemp: Double
    let condition: WeatherCondition?

    var id: Date { date }
}

extension ForecastResponse {
    /// Collapses the three-hourly entries into one summary per calendar day.
    func dailySummaries(calendar: Calendar = .current) -> [DailyForecast] {
        let grouped = Dictionary(grouping: list) { entry in
            calendar.startOfDay(for: entry.date)
        }

        return grouped.keys.sorted().compactMap { day in
            guard let entries = grouped[day], !entries.isEmpty else { return nil }

            // The entry closest to midday best represents the whole day.
            let midday = entries.min { first, second in
                abs(calendar.component(.hour, from: first.date) - 12)
                    < abs(calendar.component(.hour, from: second.date) - 12)
            }

            return DailyForecast(
                date: day,
                minTemp: entries.map(\.main.tempMin).min() ?? 0,
                maxTemp: entries.map(\.main.tempMax).max() ?? 0,
                condition: midday?.condition
            )
        }
    }
}
