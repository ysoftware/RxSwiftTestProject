//
//  Restaurant.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import RxSwift
import RxCocoa
import Foundation

// MARK: - View Model
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

// MARK: - Model

struct Restaurant: Decodable {
//    let id: Int
    let name: String
    let cuisine: Cuisine
}

enum Cuisine: String, Decodable, CaseIterable {
    case italian
    case japanese
    case american
    case mixed
    case vegan
    case korean
}
