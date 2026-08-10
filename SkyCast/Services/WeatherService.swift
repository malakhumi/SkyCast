//  WeatherService.swift
//  SkyCast


import Foundation

protocol WeatherService {
    func currentWeather(forCity city: String) async throws -> CurrentWeatherResponse
    func currentWeather(latitude: Double, longitude: Double) async throws -> CurrentWeatherResponse
    func forecast(forCity city: String) async throws -> ForecastResponse
    func forecast(latitude: Double, longitude: Double) async throws -> ForecastResponse
    func searchCities(matching query: String) async throws -> [GeocodingResult]
}
