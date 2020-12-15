//
//  RestaurantsViewModel.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import RxSwift

class RestaurantsViewModel {

    // MARK: - Public

    let title = "Restaurants"

    func fetchRestaurantsViewModels() -> Observable<[RestaurantViewModel]> {
        refresh()
        return subject.asObservable()
    }

    func refresh() {
        disposableRequest?.dispose()
        runRequest()
    }

    // MARK: - Initialization

    deinit {
        disposableRequest?.dispose()
        subject.dispose()
    }

    // MARK: Dependencies
    private let restaurantsService: IRestaurantsService

    init(restaurantsService: IRestaurantsService) {
        self.restaurantsService = restaurantsService
    }

    // MARK: - Private

    // MARK: Observables
    private let subject = PublishSubject<[RestaurantViewModel]>()
    private var disposableRequest: Disposable?

    // MARK: Method
    private func runRequest() {
        disposableRequest = restaurantsService
            .fetchRestaurants()
            .map { $0.map(RestaurantViewModel.init) }
            .subscribe { [weak self] value in
                guard let self = self else { return }
                self.subject.onNext(value)
            } onError: { [weak self] error in
                guard let self = self else { return }
                self.subject.onError(error)
            } onDisposed: {
                self.disposableRequest?.dispose()
                self.disposableRequest = nil
            }
    }
}
