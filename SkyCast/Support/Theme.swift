//  Theme.swift
//  SkyCast

import SwiftUI

struct SkyTheme {
    let isNight: Bool
    let gradientTop: Color
    let gradientBase: Color
    let card: Color
    let accent: Color
    let primaryText: Color
    let mutedText: Color
    let iconCloud: Color
    let iconMoon: Color
    let iconRain: Color
    
    static let night = SkyTheme(
        isNight: true,
        gradientTop: Color(red: 0.04, green: 0.11, blue: 0.20),
        gradientBase: Color(red: 0.09, green: 0.22, blue: 0.37),
        card: Color.white.opacity(0.08),
        accent: Color(red: 1.00, green: 0.82, blue: 0.29),
        primaryText: .white,
        mutedText: Color(red: 0.66, green: 0.77, blue: 0.86),
        iconCloud: .white,
        iconMoon: Color(red: 0.87, green: 0.91, blue: 0.97),
        iconRain: Color(red: 0.55, green: 0.75, blue: 0.95)
    )
    
    static let day = SkyTheme(
        isNight: false,
        gradientTop: Color(red: 0.92, green: 0.96, blue: 0.99),
        gradientBase: Color(red: 0.75, green: 0.89, blue: 0.97),
        card: Color.white.opacity(0.75),
        accent: Color(red: 0.96, green: 0.65, blue: 0.14),
        primaryText: Color(red: 0.10, green: 0.25, blue: 0.38),
        mutedText: Color(red: 0.35, green: 0.50, blue: 0.62),
        iconCloud: Color(red: 0.45, green: 0.58, blue: 0.70),
        iconMoon: Color(red: 0.36, green: 0.49, blue: 0.62),
        iconRain: Color(red: 0.33, green: 0.55, blue: 0.78)
    )
}
