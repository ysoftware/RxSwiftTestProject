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

    var viewModel: RestaurantsViewModel!
    var scheduler: TestScheduler!

    override func setUp() {
        let fileService = FileService()
        let restaurantService = LocalRestaurantsService(fileService: fileService)
        restaurantService.delaysOutput = false
        restaurantService.shouldRandomlySkipElements = false
        restaurantService.shouldRandomlySwitchCodeToError = false
        viewModel = RestaurantsViewModel(restaurantsService: restaurantService)
        scheduler = TestScheduler(initialClock: 0)
    }

    func test() {

        // when
        viewModel.initiate()
        let messageResult = scheduler.start { self.viewModel.messageLabel }
        let restaurantsResult = scheduler.start {
            self.viewModel.restaurants.map { viewModels in
                viewModels.map(\.restaurant.name)
            }
        }

        // then
        let messageEvents = Recorded.events([
            .next(200, "") // 200 is .created
        ])

        let restaurantsEvents = Recorded.events([
            .next(1000, [ // @Todo: why 1000? (.disposed)
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

        XCTAssertEqual(messageResult.events, messageEvents)
        XCTAssertEqual(restaurantsResult.events, restaurantsEvents)
    }
}
