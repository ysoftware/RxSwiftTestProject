//
//  ReviewsViewModel.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 16.12.2020.
//

import RxSwift
import RxCocoa

class ReviewsViewModel {

    var title: String { restaurantViewModel.restaurant.name }

    var isFavourite: BehaviorRelay<Bool> {
        restaurantViewModel.isFavourite
    }

    // MARK: Dependencies
    private let reviewsService: IReviewsService
    private let restaurantViewModel: RestaurantViewModel

    init(restaurantViewModel: RestaurantViewModel, reviewsService: IReviewsService) {
        self.reviewsService = reviewsService
        self.restaurantViewModel = restaurantViewModel
    }
}
