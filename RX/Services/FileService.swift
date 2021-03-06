//
//  JSONService.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 12.12.2020.
//

import RxSwift

protocol IFileService {
    func fetchJSON(fileName: String) -> Observable<Data>
}

class FileService { }

extension FileService: IFileService {
    func fetchJSON(fileName: String) -> Observable<Data> {
        Observable.create { observer -> Disposable in
            guard let path = Bundle.main.path(forResource: fileName, ofType: "json")
            else {
                observer.onError(JSONError.fileNotFound)
                return Disposables.create()
            }
            do {
                let data = try Data(
                    contentsOf: URL(fileURLWithPath: path),
                    options: .mappedIfSafe
                )
                observer.onNext(data)
            } catch {
                observer.onError(error)
            }
            observer.onCompleted()
            return Disposables.create()
        }
    }
}

enum JSONError: Error, LocalizedError {
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "File was not found"
        }
    }
}
