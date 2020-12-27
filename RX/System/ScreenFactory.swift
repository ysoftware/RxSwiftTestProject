//
//  ScreenFactory.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 23.12.2020.
//

import UIKit

protocol ImplementsNavigation: class {
    var screenFactory: ScreenFactory! { get set }
}

class ScreenFactory {
    private let fileService: IFileService
    private let restaurantService: IRestaurantsService
    private let reviewsService: IReviewsService

    init() {
        fileService = FileService()
        restaurantService = LocalRestaurantsService(fileService: fileService)
        reviewsService = ReviewsService(fileService: fileService)
    }

    func createRestaurantsScreen() -> UIViewController {
        let restaurantsViewController = RestaurantsViewController()
        restaurantsViewController.viewModel = RestaurantListViewModel(restaurantsService: restaurantService)
        return setup(restaurantsViewController)
    }

    func createReviewsScreen(restaurant: Restaurant) -> UIViewController {
        let reviewsViewController = ReviewsViewController()
        reviewsViewController.viewModel = ReviewsViewModel(
            restaurant: restaurant,
            reviewsService: reviewsService
        )
        return setup(reviewsViewController)
    }

    private func setup(_ viewController: UIViewController) -> UIViewController {
        if let controller = viewController as? ImplementsNavigation {
            controller.screenFactory = self
        }
        return viewController
    }
}


