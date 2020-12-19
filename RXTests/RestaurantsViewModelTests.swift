//
//  RestaurantsViewModelTests.swift
//  RXTests
//
//  Created by Ерохин Ярослав Игоревич on 19.12.2020.
//

import XCTest
import RxSwift
@testable import RX

class RestaurantsViewModelTests: XCTestCase {

    var viewModel: RestaurantsViewModel!

    override func setUp() {
        let fileService = FileService()
        let restaurantService = LocalRestaurantsService(fileService: fileService)
        viewModel = RestaurantsViewModel(restaurantsService: restaurantService)
    }

    func test() {
        
    }
}
