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
    let tags = Cuisine.allCases

    private var messageLabelRelay = BehaviorRelay(value: "")
    var messageLabel: Observable<String> {
        messageLabelRelay.asObservable()
    }
    
    private let allRestaurantsRelay = BehaviorRelay<[RestaurantViewModel]>(value: [])
    private var filteredRestaurantsRelay = BehaviorRelay<[RestaurantViewModel]>(value: [])
    var restaurants: Observable<[RestaurantViewModel]> {
        filteredRestaurantsRelay.asObservable()
    }

    // MARK: - Input
    var itemSelectedObserver = PublishSubject<Int>()
    var selectedFiltersObserver = BehaviorRelay<Set<Cuisine>>(value: [])
    var refreshObserver = PublishSubject<Void>()
    var filterTapObserver = PublishSubject<UITapGestureRecognizer>()

    func initiate() {
        runRequest()

        requestRelay
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
                .just("An error occured:\n \(error.localizedDescription)")
            }
            .bind(to: messageLabelRelay)
            .disposed(by: disposeBag)

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
            .subscribe(onNext: { [weak self] in
                self?.runRequest()
            })
            .disposed(by: disposeBag)

        filterTapObserver
            .subscribe(onNext: { [weak self] gestureRecognizer in
                guard let self = self else { return }
                let tag = self.tags[gestureRecognizer.view!.tag]
                var newValue = self.selectedFiltersObserver.value
                if newValue.contains(tag) {
                    newValue.remove(tag)
                } else {
                    newValue.insert(tag)
                }
                self.selectedFiltersObserver.accept(newValue)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private

    private let disposeBag = DisposeBag()
    private var requestHandle: Disposable?
    private var requestRelay = PublishRelay<[RestaurantViewModel]>()

    private func runRequest() {
        requestHandle?.dispose()

        requestHandle = restaurantsService
            .fetchRestaurants()
            .map { $0.map(RestaurantViewModel.init) }
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
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
