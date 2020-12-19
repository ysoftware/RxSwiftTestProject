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
    let title: Observable<String> = BehaviorRelay(value: "Restaurants").asObservable()

    private let tagsRelay = BehaviorRelay(value: Cuisine.allCases)
    var tags: [Cuisine] {
        tagsRelay.value
    }

    private let messageLabelRelay = BehaviorRelay(value: "")
    var messageLabel: Observable<String> {
        messageLabelRelay.asDriver().asObservable()
    }
    
    private let allRestaurantsRelay = BehaviorRelay<[RestaurantViewModel]>(value: [])
    private let filteredRestaurantsRelay = BehaviorRelay<[RestaurantViewModel]>(value: [])
    var restaurants: Observable<[RestaurantViewModel]> {
        filteredRestaurantsRelay.asDriver().asObservable()
    }

    private let refreshRelay = BehaviorRelay<Bool>(value: false)
    var isRefreshing: Observable<Bool> {
        refreshRelay.asDriver().asObservable()
    }

    // MARK: - Input
    var itemSelectedObserver = PublishRelay<Int>()
    var selectedFiltersObserver = BehaviorRelay<Set<Cuisine>>(value: [])
    var refreshObserver = PublishRelay<Void>()
    var filterTapObserver = PublishRelay<UITapGestureRecognizer>()

    func initiate() {
        runRequest()

        // MARK: Output

        requestRelay
            .catchErrorJustReturn([])
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
            .catchError { error in
                .just("An error occured:\n\(error.localizedDescription)")
            }
            .bind(to: messageLabelRelay)
            .disposed(by: disposeBag)

        // MARK: Input

        Observable
            .combineLatest(
                allRestaurantsRelay.catchErrorJustReturn([]),
                selectedFiltersObserver
            )
            .map { restaurants, selectedFilters in
                restaurants.filter {
                    selectedFilters.contains($0.restaurant.cuisine) || selectedFilters.isEmpty
                }
            }
            .bind(to: filteredRestaurantsRelay)
            .disposed(by: disposeBag)

        refreshObserver
            .bind { [weak self] in
                guard let self = self else { return }
                self.runRequest()
            }
            .disposed(by: disposeBag)

        filterTapObserver
            .bind { [weak self] gestureRecognizer in
                guard let self = self else { return }
                let tag = self.tagsRelay.value[gestureRecognizer.view!.tag]
                var newValue = self.selectedFiltersObserver.value
                if newValue.contains(tag) {
                    newValue.remove(tag)
                } else {
                    newValue.insert(tag)
                }
                self.selectedFiltersObserver.accept(newValue)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Private

    private let disposeBag = DisposeBag()
    private var requestHandle: Disposable?
    private var requestRelay = PublishSubject<[RestaurantViewModel]>()

    private func runRequest() {
        requestHandle?.dispose()

        requestHandle = restaurantsService
            .fetchRestaurants()
            .map { $0.map(RestaurantViewModel.init) }
            .map { value in
                self.refreshRelay.accept(false)
                return value
            }
            .bind(to: requestRelay)
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
