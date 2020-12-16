//
//  ReviewModel.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 16.12.2020.
//

import Foundation

struct Review: Decodable {
    let name: String
    let review: String
    let rating: Int
}

// MARK: - View Model
struct ReviewViewModel {
    let review: Review

    init(review: Review) {
        self.review = review
    }
}
