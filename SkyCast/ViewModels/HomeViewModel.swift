//  HomeViewModel.swift
//  SkyCast


import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {

    enum State {
        case idle
        case loading
        case loaded(CurrentWeatherResponse)
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

    func load() async {
        state = .loading
        do {
            let coordinate = try await locationService.currentLocation()
            let weather = try await service.currentWeather(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            state = .loaded(weather)
        } catch {
            await loadFallback()
        }
    }

    private func loadFallback() async {
        do {
            state = .loaded(try await service.currentWeather(forCity: fallbackCity))
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
