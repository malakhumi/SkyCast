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
    var city: String = "London"

    private let service: WeatherService

    init(service: WeatherService = OpenWeatherService()) {
        self.service = service
    }

    func load() async {
        state = .loading
        do {
            let weather = try await service.currentWeather(forCity: city)
            state = .loaded(weather)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
