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

    func fetchRestaurantsViewModels() -> Observable<[RestaurantViewModel]> {
        restaurantsService
            .fetchRestaurants()
            .map { array in
                array.map(RestaurantViewModel.init)
            }
    }
}
