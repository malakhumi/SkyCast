//  WeatherService.swift
//  SkyCast


import Foundation

protocol WeatherService {
    func currentWeather(forCity city: String) async throws -> CurrentWeatherResponse
}
