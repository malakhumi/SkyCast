//  DailySummaryTests.swift
//  SkyCastTests

import Testing
import Foundation
@testable import SkyCast

struct DailySummaryTests {

    /// Fixed to UTC so results don't depend on where the test runs.
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    @Test func producesOneSummaryPerCalendarDay() {
        let forecast = makeForecast([
            entry(day: 10, hour: 0, temp: 10, min: 8, max: 12),
            entry(day: 10, hour: 12, temp: 18, min: 15, max: 20),
            entry(day: 11, hour: 0, temp: 5, min: 4, max: 6)
        ])

        #expect(forecast.dailySummaries(calendar: calendar).count == 2)
    }

    @Test func usesTheLowestMinimumAndHighestMaximumOfTheDay() {
        let forecast = makeForecast([
            entry(day: 10, hour: 0, temp: 10, min: 8, max: 12),
            entry(day: 10, hour: 12, temp: 18, min: 15, max: 22),
            entry(day: 10, hour: 21, temp: 11, min: 6, max: 13)
        ])

        let day = forecast.dailySummaries(calendar: calendar)[0]

        #expect(day.minTemp == 6)
        #expect(day.maxTemp == 22)
    }

    @Test func picksTheConditionClosestToMidday() {
        let forecast = makeForecast([
            entry(day: 10, hour: 3, temp: 8, min: 8, max: 8, icon: "01n"),
            entry(day: 10, hour: 12, temp: 18, min: 18, max: 18, icon: "10d"),
            entry(day: 10, hour: 21, temp: 9, min: 9, max: 9, icon: "01n")
        ])

        let day = forecast.dailySummaries(calendar: calendar)[0]

        #expect(day.condition?.icon == "10d")
    }

    @Test func returnsDaysInChronologicalOrder() {
        let forecast = makeForecast([
            entry(day: 12, hour: 0, temp: 5, min: 5, max: 5),
            entry(day: 10, hour: 0, temp: 5, min: 5, max: 5),
            entry(day: 11, hour: 0, temp: 5, min: 5, max: 5)
        ])

        let days = forecast.dailySummaries(calendar: calendar)
        let sorted = days.map(\.date).sorted()

        #expect(days.map(\.date) == sorted)
    }

    @Test func handlesASingleReadingForADay() {
        let forecast = makeForecast([
            entry(day: 10, hour: 21, temp: 9, min: 7, max: 11)
        ])

        let days = forecast.dailySummaries(calendar: calendar)

        #expect(days.count == 1)
        #expect(days[0].minTemp == 7)
        #expect(days[0].maxTemp == 11)
    }

    @Test func returnsNothingForAnEmptyForecast() {
        #expect(makeForecast([]).dailySummaries(calendar: calendar).isEmpty)
    }

    // MARK: Helpers

    private func entry(
        day: Int,
        hour: Int,
        temp: Double,
        min: Double,
        max: Double,
        icon: String = "01d"
    ) -> ForecastResponse.Entry {
        var components = DateComponents()
        components.year = 2026
        components.month = 8
        components.day = day
        components.hour = hour

        let date = calendar.date(from: components)!

        return ForecastResponse.Entry(
            dt: Int(date.timeIntervalSince1970),
            main: WeatherMetrics(
                temp: temp,
                feelsLike: temp,
                tempMin: min,
                tempMax: max,
                humidity: 50
            ),
            weather: [
                WeatherCondition(id: 800, main: "Clear", description: "clear sky", icon: icon)
            ],
            wind: Wind(speed: 3, deg: 90, gust: nil),
            pop: 0
        )
    }

    private func makeForecast(_ entries: [ForecastResponse.Entry]) -> ForecastResponse {
        ForecastResponse(
            list: entries,
            city: ForecastResponse.City(name: "Testville", country: "GB", timezone: 0)
        )
    }
}
