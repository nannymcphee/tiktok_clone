//
//  UserRepo.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import RxSwift
import RxCocoa
import Resolver

protocol UserRepo {
    var authObservable: Observable<TTUser?> { get }
    var currentUser: TTUser? { get set }
    
    func getCurrentUserInfo() -> Single<TTUser?>
    func getUserInfo(userId: String) -> Single<TTUser?>
    func signInWithGoogle(presenting: UIViewController) -> Single<TTUser>
    func signOut() -> Single<Void>
}

final class UserRepoImpl: UserRepo {
    @Injected private var authService: AuthUseCase
    @Injected private var userDefaults: KeyValueStoreType
    
    private let disposeBag = DisposeBag()
    private let authRelay = BehaviorRelay<TTUser?>(value: nil)
    
    var authObservable: Observable<TTUser?> {
        return self.authRelay.asObservable()
    }
    
    var currentUser: TTUser? {
        get { return authRelay.value }
        set { authRelay.accept(newValue) }
    }
    
    init() {
        authRelay.accept(userDefaults.user)
        authObservable
            .do(onNext: { [weak self] (user) in
                self?.userDefaults.user = user
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
        
    func getCurrentUserInfo() -> Single<TTUser?> {
        guard let userId = currentUser?.id else { return .just(nil) }
        
        return authService.getUserInfo(userId: userId)
            .do(onSuccess: { [weak self] user in
                self?.userDefaults.user = user
                self?.currentUser = user
            })
    }
    
    func getUserInfo(userId: String) -> Single<TTUser?> {
        return authService.getUserInfo(userId: userId)
    }
    
    func signInWithGoogle(presenting: UIViewController) -> Single<TTUser> {
        return authService.signInWithGoogle(presenting: presenting)
            .do(onSuccess: { [weak self] user in
                self?.currentUser = user
                self?.userDefaults.user = user
            })
    }
    
    func signOut() -> Single<Void> {
        return authService.signOut()
            .do(onSuccess: { [weak self] in
                self?.currentUser = nil
                self?.userDefaults.user = nil
            })
    }
}
