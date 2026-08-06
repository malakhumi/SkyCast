//  WeatherComponents.swift
//  SkyCast

import Foundation

struct WeatherCondition: Codable, Hashable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct WeatherMetrics: Codable, Hashable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
}

struct Wind: Codable, Hashable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct Coordinates: Codable, Hashable {
    let lat: Double
    let lon: Double
}
