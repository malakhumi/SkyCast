//  HomeViewModelTests.swift
//  SkyCastTests

import Testing
import Foundation
@testable import SkyCast

@MainActor
struct HomeViewModelTests {

    @Test func loadingACitySetsLoadedState() async {
        let service = MockWeatherService()
        service.currentWeatherToReturn = .stub(name: "London", temp: 18)
        let viewModel = HomeViewModel(service: service)

        await viewModel.load(for: .stub(name: "London"))

        guard case .loaded(let snapshot) = viewModel.state else {
            Issue.record("Expected loaded state, got \(viewModel.state)")
            return
        }
        #expect(snapshot.current.name == "London")
        #expect(snapshot.current.main.temp == 18)
    }

    @Test func requestsTheCoordinatesOfTheChosenCity() async {
        let service = MockWeatherService()
        let viewModel = HomeViewModel(service: service)

        await viewModel.load(for: .stub())

        #expect(service.requestedCoordinates.first?.lat == 51.5)
        #expect(service.requestedCoordinates.first?.lon == -0.12)
    }

    @Test func keepsOnlyTheNextEightHourlyEntries() async {
        let service = MockWeatherService()
        service.forecastToReturn = .stub(entryCount: 40)
        let viewModel = HomeViewModel(service: service)

        await viewModel.load(for: .stub())

        guard case .loaded(let snapshot) = viewModel.state else {
            Issue.record("Expected loaded state")
            return
        }
        #expect(snapshot.hourly.count == 8)
    }

    @Test func keepsAtMostFiveDays() async {
        let service = MockWeatherService()
        service.forecastToReturn = .stub(entryCount: 40)
        let viewModel = HomeViewModel(service: service)

        await viewModel.load(for: .stub())

        guard case .loaded(let snapshot) = viewModel.state else {
            Issue.record("Expected loaded state")
            return
        }
        #expect(snapshot.daily.count <= 5)
    }

    @Test func failureSetsFailedStateWithAMessage() async {
        let service = MockWeatherService()
        service.errorToThrow = WeatherError.cityNotFound
        let viewModel = HomeViewModel(service: service)

        await viewModel.load(for: .stub())

        guard case .failed(let message) = viewModel.state else {
            Issue.record("Expected failed state, got \(viewModel.state)")
            return
        }
        #expect(message == WeatherError.cityNotFound.errorDescription)
    }

    @Test func nightIconSelectsTheNightTheme() async {
        let service = MockWeatherService()
        service.currentWeatherToReturn = .stub(icon: "01n")
        let viewModel = HomeViewModel(service: service)

        await viewModel.load(for: .stub())

        #expect(viewModel.isNight)
        #expect(viewModel.theme.isNight)
    }

    @Test func dayIconSelectsTheDayTheme() async {
        let service = MockWeatherService()
        service.currentWeatherToReturn = .stub(icon: "01d")
        let viewModel = HomeViewModel(service: service)

        await viewModel.load(for: .stub())

        #expect(viewModel.isNight == false)
    }

    @Test func startsIdle() {
        let viewModel = HomeViewModel(service: MockWeatherService())
        guard case .idle = viewModel.state else {
            Issue.record("Expected idle state")
            return
        }
    }
}
