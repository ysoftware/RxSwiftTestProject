//
//  AppCoordinator.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import UIKit

class AppCoordinator {

    private let window: UIWindow
    private let screenFactory = ScreenFactory()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let restaurantsViewController = screenFactory.createRestaurantsScreen()
        window.rootViewController = UINavigationController(rootViewController: restaurantsViewController)
        window.makeKeyAndVisible()
    }
}
