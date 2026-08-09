//  HomeViewModel.swift
//  SkyCast


import Foundation
import Observation



struct WeatherSnapshot {
    let current: CurrentWeatherResponse
    let hourly: [ForecastResponse.Entry]
    let daily: [DailyForecast]
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
        WeatherSnapshot(
            current: current,
            hourly: Array(forecast.list.prefix(8)),
            daily: forecast.dailySummaries()
        )
    }

    func load() async {
        state = .loading
        do {
            let coordinate = try await locationService.currentLocation()
            //async let is used here because you are making two independent network requests, and you want them to run at the same time.
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
