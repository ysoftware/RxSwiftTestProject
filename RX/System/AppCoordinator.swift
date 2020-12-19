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
        let fileService = FileService()
        let restaurantService = LocalRestaurantsService(fileService: fileService)

        let restaurantsViewController = RestaurantsViewController()
        restaurantsViewController.viewModel = RestaurantsViewModel(restaurantsService: restaurantService)

        window.rootViewController = UINavigationController(rootViewController: restaurantsViewController)
        window.makeKeyAndVisible()
    }
}
