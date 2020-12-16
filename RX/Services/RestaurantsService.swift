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

class RestaurantsService {
    init(fileService: IFileService) {
        self.fileService = fileService
    }

    // MARK: Dependencies
    let fileService: IFileService
}

extension RestaurantsService: IRestaurantsService {
    func fetchRestaurants() -> Observable<[Restaurant]> {
        Observable.create { observer -> Disposable in
            self.fileService
                .fetchJSON(fileName: "Restaurants")
                .parseJSONIntoResponse()
                .skipRandomElements()
                .handleResponse(with: observer)
        }
    }
}
