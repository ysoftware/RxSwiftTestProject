//
//  ReviewsViewModel.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 16.12.2020.
//

import RxSwift

class ReviewsViewModel {

    var title: String { restaurant.name }

    // MARK: Dependencies
    private let reviewsService: IReviewsService
    private let restaurant: Restaurant

    init(restaurant: Restaurant, reviewsService: IReviewsService) {
        self.reviewsService = reviewsService
        self.restaurant = restaurant
    }
}
