//  HomeViewModel.swift
//  SkyCast


import Foundation
import Observation



struct WeatherSnapshot {
    let current: CurrentWeatherResponse
    let hourly: [ForecastResponse.Entry]
    let daily: [DailyForecast]
    /// The displayed city's timezone, so all times read as local to that city.
    let timeZone: TimeZone
}


@MainActor
@Observable

final class HomeViewModel {

    enum State {
        case idle
        case loading
        case loaded(WeatherSnapshot)
        case failed(String)
    }
    
    var isNight: Bool {
        if case .loaded(let snapshot) = state { return snapshot.current.isNight }
        return true
    }

    var theme: SkyTheme { isNight ? .night : .day }

    private(set) var state: State = .idle

    private let service: WeatherService
    private let locationService = LocationService()

    /// Used when location is denied or unavailable.
    var fallbackCity = "London"

    init(service: WeatherService = OpenWeatherService()) {
        self.service = service
    }
    
    private func makeSnapshot(
        current: CurrentWeatherResponse,
        forecast: ForecastResponse
    ) -> WeatherSnapshot {
        let timeZone = TimeZone(secondsFromGMT: forecast.city.timezone) ?? .current

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        return WeatherSnapshot(
            current: current,
            hourly: Array(forecast.list.prefix(8)),
            daily: Array(forecast.dailySummaries(calendar: calendar).prefix(5)),
            timeZone: timeZone
        )
    }
    
    private enum Source {
        case deviceLocation
        case city(GeocodingResult)
    }

    private var source: Source = .deviceLocation

    func load() async {
        switch source {
        case .deviceLocation:
            await loadFromDeviceLocation()
        case .city(let city):
            await loadCity(city)
        }
    }

    func load(for city: GeocodingResult) async {
        source = .city(city)
        await loadCity(city)
    }

    private func loadFromDeviceLocation() async {
        state = .loading
        do {
            let coordinate = try await locationService.currentLocation()
            async let current = service.currentWeather(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            async let forecast = service.forecast(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            state = .loaded(
                makeSnapshot(current: try await current, forecast: try await forecast)
            )
        } catch {
            await loadFallback()
        }
    }
    
    func loadDeviceLocation() async {
        source = .deviceLocation
        await loadFromDeviceLocation()
    }

    private func loadCity(_ city: GeocodingResult) async {
        state = .loading
        do {
            async let current = service.currentWeather(latitude: city.lat, longitude: city.lon)
            async let forecast = service.forecast(latitude: city.lat, longitude: city.lon)
            state = .loaded(
                makeSnapshot(current: try await current, forecast: try await forecast)
            )
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
    private func loadFallback() async {
        do {
            async let current = service.currentWeather(forCity: fallbackCity)
            async let forecast = service.forecast(forCity: fallbackCity)
            state = .loaded(
                makeSnapshot(current: try await current, forecast: try await forecast)
            )
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
