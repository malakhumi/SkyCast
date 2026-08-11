//  SettingsView.swift
//  SkyCast
import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    let theme: SkyTheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [theme.gradientTop, theme.gradientBase],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            List {
                Section {
                    ForEach(TemperatureUnit.allCases) { unit in
                        selectableRow(
                            title: unit.title,
                            detail: unit.symbol,
                            isSelected: settings.temperatureUnit == unit
                        ) {
                            settings.temperatureUnit = unit
                        }
                    }
                } header: {
                    Text("Temperature").foregroundStyle(theme.mutedText)
                }

                Section {
                    ForEach(WindSpeedUnit.allCases) { unit in
                        selectableRow(
                            title: unit.title,
                            detail: unit.symbol,
                            isSelected: settings.windSpeedUnit == unit
                        ) {
                            settings.windSpeedUnit = unit
                        }
                    }
                } header: {
                    Text("Wind speed").foregroundStyle(theme.mutedText)
                }
            }
            .scrollContentBackground(.hidden)
        }
    }

    private func selectableRow(
        title: String,
        detail: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(theme.primaryText)
                Text(detail)
                    .foregroundStyle(theme.mutedText)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(theme.accent)
                        .fontWeight(.semibold)
                }
            }
            .contentShape(Rectangle())
        }
        .listRowBackground(theme.card)
    }
}

#Preview {
    NavigationStack {
        SettingsView(settings: AppSettings(), theme: .night)
    }
}
