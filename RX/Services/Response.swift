//
//  Response.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import RxSwift

// MARK: - Observable Response Handling
extension Observable {

    func parseJSONIntoResponse<T: Decodable>() -> Observable<Response<T>>
    where Element == Data
    {
        map { data -> Response<T> in
            try JSONDecoder().decode(Response<T>.self, from: data)
        }
    }

    func handleResponse<T: Decodable>() -> Observable<T>
    where Element == Response<T>
    {
        map { response in
            guard response.code == 200
            else { throw ResponseError.errorCode(response.code) }

            guard let result = response.result
            else { throw ResponseError.unexpectedEmptyResult }
            return result
        }
    }

    func skipRandomElements<T: Decodable>() -> Observable<Response<[T]>>
    where Element == Response<[T]>
    {
        map { response -> Response<[T]> in
            Response(
                code: response.code,
                result: response.result?.filter { _ in
                    Int.random(in: 0...10) > 1
                }
            )
        }
    }
}

// MARK: - Response Model

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
