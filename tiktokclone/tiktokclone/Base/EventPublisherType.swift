//
//  EventPublisherType.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import RxSwift

protocol EventPublisherType {
    associatedtype Event
    var eventPublisher: PublishSubject<Event> { get }
}
