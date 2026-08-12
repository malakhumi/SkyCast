//  ViewController.swift
//  SkyCast

import UIKit
import SwiftUI

/// UIKit shell that comes from the storyboard.
/// Its only job is to host the SwiftUI Home screen.
final class ViewController: UIViewController {

    private let viewModel = HomeViewModel()
    private let settings = AppSettings()

    override func viewDidLoad() {
        super.viewDidLoad()

        let hosting = UIHostingController(
            rootView: HomeView(
                viewModel: viewModel,
                settings: settings,
                onSearchTapped: { [weak self] in self?.showCitySearch() },
                onSettingsTapped: { [weak self] in self?.showSettings() }
            )
        )

        addChild(hosting)
        view.addSubview(hosting.view)

        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hosting.didMove(toParent: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func showCitySearch() {
        let citiesVC = CitiesViewController()
        citiesVC.theme = viewModel.theme
        citiesVC.onCitySelected = { [weak self] city in
            guard let self else { return }
            self.navigationController?.popViewController(animated: true)
            Task { await self.viewModel.load(for: city) }
        }
        navigationController?.pushViewController(citiesVC, animated: true)
    }
    
    private func showSettings() {
        let settingsVC = UIHostingController(
            rootView: SettingsView(settings: settings, theme: viewModel.theme)
        )
        settingsVC.title = "Settings"
        settingsVC.overrideUserInterfaceStyle = viewModel.theme.isNight ? .dark : .light
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}
