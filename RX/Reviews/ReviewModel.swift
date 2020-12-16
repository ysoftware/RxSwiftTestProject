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
