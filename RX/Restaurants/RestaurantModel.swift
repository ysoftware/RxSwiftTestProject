//
//  Restaurant.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import Foundation

struct Restaurant: Decodable {
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
