//
//  RestaurantsViewModel.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import RxSwift

class RestaurantsViewModel {

    let title = "Restaurants"

    func fetchRestaurantsViewModels() -> Observable<[RestaurantViewModel]> {
        runRequest()
        return subject.asObservable()
    }

    func refresh() {
        loadNewData()
    }

    // MARK: - Private

    deinit {
        disposableRequest?.dispose()
    }

    private var disposableRequest: Disposable?
    private let subject = PublishSubject<[RestaurantViewModel]>()
    private let restaurantsService = RestaurantsService()

    private func runRequest() {
        disposableRequest = restaurantsService
            .fetchRestaurants()
            .map { $0.map(RestaurantViewModel.init) }
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.subject.onNext($0)
                self.disposableRequest = nil
                self.disposableRequest?.dispose()
            })
    }

    private func loadNewData() {
        disposableRequest?.dispose()
        runRequest()
    }
}
