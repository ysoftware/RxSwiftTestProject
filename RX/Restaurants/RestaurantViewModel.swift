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
    private var isFavouriteRelay = BehaviorRelay<Bool>(value: false)

    // MARK: Output

    let restaurant: Restaurant // @Todo: make private?

    var isFavouriteInstantValue: Bool {
        isFavouriteRelay.value
    }

    var isFavourite: Observable<Bool> {
        isFavouriteRelay.asObservable()
    }

    // MARK: Input

    func setIsFavourite(_ value: Bool) {
        if value {
            UserDefaults.standard.setValue(true, forKey: isFavouriteKey)
        } else {
            UserDefaults.standard.removeObject(forKey: isFavouriteKey)
        }
    }

    // MARK: Setup

    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        setup()
    }

    private func setup() {
        UserDefaults.standard.rx
            .observe(Bool.self, isFavouriteKey)
            .map { $0 ?? false }
            .bind(to: isFavouriteRelay)
            .disposed(by: disposeBag)
    }
}
