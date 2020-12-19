//
//  Debug.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 19.12.2020.
//

import RxSwift

extension ObservableType {

    public func debug(
        onEvent: ((Event<Self.Element>) -> Void)? = nil,
        onDispose: (() -> Void)? = nil
    ) -> Observable<Self.Element> {
        Observable.create { observer in
            let subscription = subscribe { event in
                onEvent?(event)
                switch event {
                case .next(let value):
                    observer.on(.next(value))
                case .error(let error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            }
            return Disposables.create {
                onDispose?()
                subscription.dispose()
            }
        }
    }

    public func debug(
        onNext: ((Self.Element) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        onCompleted: (() -> Void)? = nil,
        onDispose: (() -> Void)? = nil
    ) -> Observable<Self.Element> {
        Observable.create { observer in
            let subscription = subscribe { event in
                switch event {
                case .next(let value):
                    onNext?(value)
                    observer.on(.next(value))
                case .error(let error):
                    onError?(error)
                    observer.on(.error(error))
                case .completed:
                    onCompleted?()
                    observer.on(.completed)
                }
            }
            return Disposables.create {
                onDispose?()
                subscription.dispose()
            }
        }
    }
}
