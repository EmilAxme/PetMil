//
//  SceneDelegate.swift
//  PetMil
//
//  Created by Emil on 04.03.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let rootViewController = WeatherAssembly.build()
        let navigationController = UINavigationController(rootViewController: rootViewController)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window
    }
}
