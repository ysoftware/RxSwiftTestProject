//
//  RestaurantsService.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import Foundation
import RxSwift

protocol IRestaurantsService {
    func fetchRestaurants() -> Observable<[Restaurant]>
}

class LocalRestaurantsService {
    init(fileService: IFileService) {
        self.fileService = fileService
    }

    var delaysOutput = true
    var shouldRandomlySkipElements = true
    var shouldRandomlySwitchCodeToError = true

    // MARK: Dependencies
    let fileService: IFileService
}

extension LocalRestaurantsService: IRestaurantsService {
    func fetchRestaurants() -> Observable<[Restaurant]> {
        fileService
            .fetchJSON(fileName: "Restaurants")
            .delayIfNeeded(delaysOutput)
            .parseJSONIntoResponse()
            .skipRandomElements(shouldRandomlySkipElements)
            .randomlySwitchCodeToError(shouldRandomlySwitchCodeToError)
            .handleResponse()
    }
}
