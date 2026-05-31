//
//  SettingsAssembly.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import UIKit

enum SettingsAssembly {
    static func build() -> UIViewController {
        let settingsViewController = SettingsViewController()
        let navigation = UINavigationController(rootViewController: settingsViewController)
        navigation.modalPresentationStyle = .pageSheet
        if let sheet = navigation.sheetPresentationController {
            sheet.detents = [.large(), .medium()]
            sheet.prefersGrabberVisible = true
        }
        return navigation
    }
}
