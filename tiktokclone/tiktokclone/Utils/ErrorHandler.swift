//
//  ErrorHandler.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit

typealias CallBackClosure = () -> Void

enum ErrorAction: Equatable {
    case alert
    case log
    
    static func == (lhs: ErrorAction, rhs: ErrorAction) -> Bool {
        switch lhs {
        case .log:
            switch rhs {
            case .log:
                return true
            default:
                return false
            }
        case .alert:
            switch rhs {
            case .alert:
                return true
            default:
                return false
            }
        }
    }
}

protocol ErrorHandler {
    func handle<T>(error: T?, action: ErrorAction?, completion: CallBackClosure?)
    func handle(errorMessage: String, action: ErrorAction?, completion: CallBackClosure?)
}

extension ErrorHandler {
    func handle<T>(error: T?, action: ErrorAction? = .log, completion: CallBackClosure? = nil) {
        var mutableAction = action
        
        #if DEBUG
        if mutableAction == .log {
            mutableAction = .alert
        }
        #endif
        
        if let err = error as? Error {
            handle(errorMessage: err.localizedDescription, action: mutableAction, completion: completion)
        } else if let errMsg = error as? String {
            handle(errorMessage: errMsg, action: mutableAction, completion: completion)
        } else if let unwrap = error {
            handle(errorMessage: String(describing: unwrap), action: mutableAction, completion: completion)
        } else {
            handle(errorMessage: "Unknow error !!!", action: mutableAction, completion: completion)
        }
    }
    
    func handle(errorMessage: String, action: ErrorAction? = .log, completion: CallBackClosure? = nil) {
        switch action {
        case .log:
            Logger.e(errorMessage)
            completion?()
        case .alert:
            guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
                Logger.e("Handle error failed: rootVC not found!!!")
                return
            }
            AppDialog.withOk(controller: rootVC, title: Text.error, message: errorMessage)
        case .none:
            completion?()
        }
    }
}
