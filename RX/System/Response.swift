//
//  Response.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import Foundation

struct Response<Data: Decodable>: Decodable {

    let code: Int
    let result: Data?
}

enum ResponseError: Error {
    case errorCode(Int)
    case unexpectedEmptyResult
}
