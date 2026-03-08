//
//  SceneDelegate.swift
//  PetMil
//
//  Created by Emil on 04.03.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let rootVC = WeatherAssembly.build()
        let navigation = UINavigationController(rootViewController: rootVC)

        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
    }
}

