//
//  Response.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import RxSwift

extension Observable {

    func parseJSONIntoResponse<T: Decodable>() -> Observable<Response<[T]>>
    where Element == Data
    {
        flatMap { data -> Observable<Response<[T]>> in
            do {
                let response = try JSONDecoder().decode(Response<[T]>.self, from: data)
                return .just(response)
            } catch {
                return Observable<Response<[T]>>.error(error)
            }
        }
    }

    func handleResponse<T: Decodable>(with observer: AnyObserver<T>) -> Disposable
    where Element == Response<T>
    {
        subscribe { response in
            if response.code == 200 {
                if let result = response.result {
                    observer.onNext(result)
                } else {
                    observer.onError(ResponseError.unexpectedEmptyResult)
                }
            } else {
                observer.onError(ResponseError.errorCode(response.code))
            }
        } onError: { error in
            observer.onError(error)
        }
    }

    func skipRandomElements<T: Decodable>() -> Observable<Response<[T]>>
    where Element == Response<Array<T>>
    {
        map { response -> Response<[T]> in
            let result = response.result?.filter { _ in Int.random(in: 0...10) > 1 }
            return Response(code: response.code, result: result)
        }
    }
}

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
