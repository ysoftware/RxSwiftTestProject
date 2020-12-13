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

enum ResponseError: Error, LocalizedError {
    case errorCode(Int)
    case unexpectedEmptyResult

    var errorDescription: String? {
        switch self {
        case .errorCode(let code):
            return "Code \(code)"
        case .unexpectedEmptyResult:
            return "Response came back with a missing result object"
        }
    }
}
