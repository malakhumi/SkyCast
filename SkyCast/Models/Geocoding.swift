//  Geocoding.swift
//  SkyCast

import Foundation
struct GeocodingResult: Codable, Hashable, Identifiable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?

    var id: String { "\(name)-\(lat)-\(lon)" }

    /// e.g. "London, England, GB"
    var displayName: String {
        [name, state, country].compactMap { $0 }.joined(separator: ", ")
    }
}

extension GeocodingResult {
    /// "GB" → "United Kingdom", "CO" → "Colombia"
    var countryName: String {
        Locale.current.localizedString(forRegionCode: country) ?? country
    }
}
