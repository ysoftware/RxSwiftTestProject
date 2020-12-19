//
//  Response.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import RxSwift

// MARK: - Instability Simulation
extension ObservableType {

    func delayIfNeeded(_ shouldDelay: Bool) -> Observable<Element> {
        flatMap { value -> Observable<Element> in
            var output = Observable.just(value)
            if shouldDelay {
                let delayTime: RxTimeInterval = .milliseconds(Int.random(in: 20...2000))
                output = output.delay(delayTime, scheduler: MainScheduler.instance)
            }
            return output
        }
    }

    func randomlySwitchCodeToError<T: Decodable>(_ shouldSwitchCode: Bool) -> Observable<Response<T>>
    where Element == Response<T>
    {
        map { response in
            if shouldSwitchCode, response.code == 200, Int.random(in: 0...10) > 6 {
                return Response(code: 400, result: response.result)
            }
            return response
        }
    }

    func skipRandomElements<T: Decodable>(_ shouldSkip: Bool) -> Observable<Response<[T]>>
    where Element == Response<[T]>
    {
        map { response -> Response<[T]> in
            Response(
                code: response.code,
                result: response.result?.filter { _ in
                    !(shouldSkip && Int.random(in: 0...10) < 1)
                }
            )
        }
    }
}

// MARK: - Observable Response Handling
extension ObservableType {

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
