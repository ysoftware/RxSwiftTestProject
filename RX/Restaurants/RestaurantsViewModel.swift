//
//  RestaurantsViewModel.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import RxSwift
import RxCocoa

class RestaurantsViewModel {

    // MARK: - Output
    let title = BehaviorRelay(value: "Restaurants").asObservable()

    var tags: [Cuisine] {
        tagsRelay.value
    }

    var messageLabel: Observable<String> {
        messageLabelRelay.asDriver().asObservable()
    }

    var restaurants: Observable<[RestaurantViewModel]> {
        filteredRestaurantsRelay.asDriver().asObservable()
    }

    var isRefreshing: Observable<Bool> {
        refreshRelay.asDriver().asObservable()
    }

    // MARK: - Input
    var selectedFiltersObserver = BehaviorRelay<Set<Cuisine>>(value: [])
    var refreshObserver = PublishRelay<Void>()
    var filterTapObserver = PublishRelay<Int>()

    // MARK: - Internal
    private let disposeBag = DisposeBag()
    private var requestHandle: Disposable?
    private var requestRelay = PublishRelay<[RestaurantViewModel]>()
    private let refreshRelay = BehaviorRelay<Bool>(value: false)
    private let tagsRelay = BehaviorRelay(value: Cuisine.allCases)
    private let allRestaurantsRelay = BehaviorRelay<[RestaurantViewModel]>(value: [])
    private let filteredRestaurantsRelay = BehaviorRelay<[RestaurantViewModel]>(value: [])
    private let messageLabelRelay = BehaviorRelay(value: "")

    func initiate() {

        // MARK: Output

        requestRelay
            .do(onNext: { [weak self] _ in
                self?.refreshRelay.accept(false)
            })
            .bind(to: allRestaurantsRelay)
            .disposed(by: disposeBag)

        requestRelay
            .map { value in
                if value.isEmpty {
                    return "Nothing was found"
                } else {
                    return ""
                }
            }
            .bind(to: messageLabelRelay)
            .disposed(by: disposeBag)

        // MARK: Input

        Observable
            .combineLatest(allRestaurantsRelay, selectedFiltersObserver)
            .map { restaurants, selectedFilters in
                restaurants.filter {
                    selectedFilters.contains($0.restaurant.cuisine) || selectedFilters.isEmpty
                }
            }
            .bind(to: filteredRestaurantsRelay)
            .disposed(by: disposeBag)

        refreshObserver
            .bind { [weak self] in
                self?.runRequest()
            }
            .disposed(by: disposeBag)

        filterTapObserver
            .bind { [weak self] elementIndex in
                guard let self = self else { return }
                let tag = self.tagsRelay.value[elementIndex]
                var newValue = self.selectedFiltersObserver.value
                if newValue.contains(tag) {
                    newValue.remove(tag)
                } else {
                    newValue.insert(tag)
                }
                self.selectedFiltersObserver.accept(newValue)
            }
            .disposed(by: disposeBag)

        runRequest()
    }

    // MARK: - Private

    private func runRequest() {
        requestHandle?.dispose()

        requestHandle = restaurantsService
            .fetchRestaurants()
            .map { $0.map(RestaurantViewModel.init) }
            .subscribe(onNext: { [weak self] value in
                self?.requestRelay.accept(value)
            }, onError: { [weak self] error in
                self?.requestRelay.accept([])
                self?.messageLabelRelay.accept("An error occured:\n\(error.localizedDescription)")
            })
    }

    // MARK: - Initialization

    deinit {
        requestHandle?.dispose()
    }

    // MARK: Dependencies
    private let restaurantsService: IRestaurantsService

    init(restaurantsService: IRestaurantsService) {
        self.restaurantsService = restaurantsService
    }
}
