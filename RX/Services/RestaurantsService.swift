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
                .flatMap { data -> Observable<Response<[Restaurant]>> in
                    do {
                        let response = try JSONDecoder().decode(Response<[Restaurant]>.self, from: data)
                        return .just(response)
                    } catch {
                        return Observable.error(error)
                    }
                }
                .subscribe { response in
                    if response.code == 200 {
                        if let result = response.result {
                            observer.onNext(result)
                        } else {
                            observer.onError(ResponseError.unexpectedEmptyResult)
                        }
                    } else {
                        observer.onError(ResponseError.errorCode(response.code))
                    }
                } onError: { error in
                    observer.onError(error)
                }
        }
    }
}
