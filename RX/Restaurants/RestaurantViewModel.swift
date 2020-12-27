//
//  RestaurantViewModel.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 27.12.2020.
//

import RxSwift
import RxCocoa

struct RestaurantViewModel {

    private var isFavouriteKey: String { "Restaurant-\(restaurant.name)-isFavourite" }
    private let disposeBag = DisposeBag()

    // MARK: - API
    let restaurant: Restaurant // @Todo: make private?
    var isFavourite = BehaviorRelay<Bool>(value: false)

    // MARK: - Setup

    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        setup()
    }

    // MARK: - Private

    private func setIsFavourite(_ value: Bool) {
        if value {
            UserDefaults.standard.setValue(true, forKey: isFavouriteKey)
        } else {
            UserDefaults.standard.removeObject(forKey: isFavouriteKey)
        }
    }

    private func setup() {
        UserDefaults.standard.rx
            .observe(Bool.self, isFavouriteKey)
            .map { $0 ?? false }
            .bind(to: isFavourite)
            .disposed(by: disposeBag)

        isFavourite
            .bind(onNext: setIsFavourite)
            .disposed(by: disposeBag)
    }
}
