//  WeatherError.swift
//  SkyCast

import Foundation

/// Things that can go wrong when fetching weather.
enum WeatherError: LocalizedError, Equatable {
    case invalidURL
    case invalidAPIKey
    case cityNotFound
    case noInternet
    case decodingFailed
    case server(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not build the request."
        case .invalidAPIKey:
            return "The API key is missing or not active yet."
        case .cityNotFound:
            return "We couldn't find that city."
        case .noInternet:
            return "No internet connection."
        case .decodingFailed:
            return "The weather data was in an unexpected format."
        case .server(let statusCode):
            return "The weather service returned an error (\(statusCode))."
        }
    }
}
