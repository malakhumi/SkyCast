//  Theme.swift
//  SkyCast

import SwiftUI

struct SkyTheme {
    let gradientTop: Color
    let gradientBase: Color
    let card: Color
    let accent: Color
    let primaryText: Color
    let mutedText: Color

    static let night = SkyTheme(
        gradientTop: Color(red: 0.04, green: 0.11, blue: 0.20),
        gradientBase: Color(red: 0.09, green: 0.22, blue: 0.37),
        card: Color.white.opacity(0.08),
        accent: Color(red: 1.00, green: 0.82, blue: 0.29),
        primaryText: .white,
        mutedText: Color(red: 0.66, green: 0.77, blue: 0.86)
    )

    static let day = SkyTheme(
        gradientTop: Color(red: 0.92, green: 0.96, blue: 0.99),
        gradientBase: Color(red: 0.75, green: 0.89, blue: 0.97),
        card: Color.white.opacity(0.75),
        accent: Color(red: 0.96, green: 0.65, blue: 0.14),
        primaryText: Color(red: 0.10, green: 0.25, blue: 0.38),
        mutedText: Color(red: 0.35, green: 0.50, blue: 0.62)
    )
}
