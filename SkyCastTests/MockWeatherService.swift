//  MockWeatherService.swift
//  SkyCastTests

import Foundation
@testable import SkyCast

final class MockWeatherService: WeatherService {

    var currentWeatherToReturn: CurrentWeatherResponse = .stub()
    var forecastToReturn: ForecastResponse = .stub()
    var searchResultsToReturn: [GeocodingResult] = []
    var errorToThrow: Error?

    private(set) var requestedCoordinates: [(lat: Double, lon: Double)] = []

    func currentWeather(forCity city: String) async throws -> CurrentWeatherResponse {
        if let errorToThrow { throw errorToThrow }
        return currentWeatherToReturn
    }

    func currentWeather(latitude: Double, longitude: Double) async throws -> CurrentWeatherResponse {
        requestedCoordinates.append((latitude, longitude))
        if let errorToThrow { throw errorToThrow }
        return currentWeatherToReturn
    }

    func forecast(forCity city: String) async throws -> ForecastResponse {
        if let errorToThrow { throw errorToThrow }
        return forecastToReturn
    }

    func forecast(latitude: Double, longitude: Double) async throws -> ForecastResponse {
        if let errorToThrow { throw errorToThrow }
        return forecastToReturn
    }

    func searchCities(matching query: String) async throws -> [GeocodingResult] {
        if let errorToThrow { throw errorToThrow }
        return searchResultsToReturn
    }
}
