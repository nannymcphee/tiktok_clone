//
//  ErrorTracker.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import RxSwift
import RxCocoa

final class ErrorTracker: SharedSequenceConvertibleType {
    typealias SharingStrategy = DriverSharingStrategy
    private let _subject = PublishSubject<(Error, ErrorAction)>()
    
    func trackError<O: ObservableConvertibleType>(from source: O, action: ErrorAction = .log) -> Observable<O.Element> {
        return source.asObservable().do(onError: {[weak self] err in
            self?.onError((err, action))
        })
    }

    func asSharedSequence() -> SharedSequence<SharingStrategy, (Error, ErrorAction)> {
        return _subject.asObservable().asDriverOnErrorJustComplete()
    }

    func asObservable() -> Observable<(Error, ErrorAction)> {
        return _subject.asObservable()
    }

    private func onError(_ error: (Error, ErrorAction)) {
        _subject.onNext(error)
    }
    
    deinit {
        _subject.onCompleted()
    }
}

extension ObservableConvertibleType {
    func trackError(_ errorTracker: ErrorTracker, action: ErrorAction = .log) -> Observable<Element> {
        return errorTracker.trackError(from: self, action: action)
    }
}
