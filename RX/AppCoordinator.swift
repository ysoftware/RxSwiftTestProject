//
//  AppCoordinator.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import UIKit

class AppCoordinator {

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let rootViewController = ViewController()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
}
