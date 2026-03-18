//
//  AppTabBarController.swift
//  PetMil
//
//  Created by Emil on 11.03.2026.
//

import UIKit

final class AppTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }
}

private extension AppTabBarController {
    func setupAppearance() {
        tabBar.tintColor = .label
        tabBar.backgroundColor = .systemBackground
    }
}
