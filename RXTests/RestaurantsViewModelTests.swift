//
//  RestaurantsViewModelTests.swift
//  RXTests
//
//  Created by Ерохин Ярослав Игоревич on 19.12.2020.
//

import XCTest
import RxSwift
import RxTest
@testable import RX

class RestaurantsViewModelTests: XCTestCase {

    var viewModel: RestaurantListViewModel!
    var scheduler: TestScheduler!

    override func setUp() {
        let fileService = FileService()
        let restaurantService = LocalRestaurantsService(fileService: fileService)
        restaurantService.delaysOutput = false
        restaurantService.shouldRandomlySkipElements = false
        restaurantService.shouldRandomlySwitchCodeToError = false
        viewModel = RestaurantListViewModel(restaurantsService: restaurantService)
        scheduler = TestScheduler(initialClock: 0)
    }

    func testRestaurants() {
        viewModel.initiate()

        let restaurantsResult = scheduler.start {
            self.viewModel.restaurants.map { viewModels in
                viewModels.map(\.restaurant.name)
            }
        }

        let restaurantsEvents = Recorded.events([
            .next(200, [
                "Чентуриппе",
                "The Park",
                "Pinsapositana",
                "Фантоцци",
                "Сыроварня",
                "#FARШ",
                "Якитория",
                "Савой",
                "K-Town",
                "Fumisawa Sushi",
                "Veганутые",
                "Burger Heroes",
            ])
        ])
        XCTAssertEqual(restaurantsResult.events, restaurantsEvents)
    }

    func testMessages() {
        viewModel.initiate()

        let messageResult = scheduler.start {
            self.viewModel.messageLabel
        }

        let messageEvents = Recorded.events([
            .next(200, "")
        ])
        XCTAssertEqual(messageResult.events, messageEvents)
    }
}
