//
//  JSONService.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import RxSwift

class FileService {

    func fetchJSON(fileName: String) -> Observable<Data> {
        Observable.create { observer -> Disposable in
            guard let path = Bundle.main.path(forResource: fileName, ofType: "json")
            else {
                observer.onError(JSONError.fileNotFound)
                return Disposables.create()
            }

            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path),
                                    options: .mappedIfSafe)
                observer.onNext(data)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }

            return Disposables.create()
        }
    }
}

enum JSONError: Error {
    case fileNotFound
}
