//
//  RestaurantsService.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import Foundation
import RxSwift

class RestaurantsService {
    let fileService = FileService()

    func fetchRestaurants() -> Observable<[Restaurant]> {
        Observable.create { observer -> Disposable in
            self.fileService
                .fetchJSON(fileName: "Restaurants")
                .subscribe { data in
                    do {
                        let response = try JSONDecoder()
                            .decode(Response<[Restaurant]>.self, from: data)
                        if response.code == 200 {
                            if let result = response.result {
                                observer.onNext(result)
                            } else {
                                observer.onError(ResponseError.unexpectedEmptyResult)
                            }
                        } else {
                            observer.onError(ResponseError.errorCode(response.code))
                        }
                    } catch {
                        observer.onError(error)
                    }
                } onError: { error in
                    observer.onError(error)
                }
        }
    }
}
