//
//  RestaurantsViewModel.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import RxSwift

class RestaurantsViewModel {

    let restaurantsService = RestaurantsService()

    let title = "Restaurants"

    func fetchRestaurantsViewModel() -> Observable<[RestaurantViewModel]> {
        restaurantsService.fetchRestaurants()
            .map { $0.map(RestaurantViewModel.init) }
    }
}
