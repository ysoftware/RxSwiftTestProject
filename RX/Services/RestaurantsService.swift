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

    // MARK: Dependencies
    let fileService: IFileService
}

extension LocalRestaurantsService: IRestaurantsService {
    func fetchRestaurants() -> Observable<[Restaurant]> {
        fileService
            .fetchJSON(fileName: "Restaurants")
            .parseJSONIntoResponse()
            .skipRandomElements()
            .randomlySwitchCodeToError()
            .handleResponse()
    }
}
