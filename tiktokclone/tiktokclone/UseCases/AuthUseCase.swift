//
//  AuthUseCase.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import RxSwift
import Firebase
import FirebaseAuth
import GoogleSignIn

enum AuthError: Error {
    case invalidToken
    case userNotFound
}

protocol AuthUseCase {
    var isLoggedIn: Observable<Bool> { get }
    
    func signInWithGoogle(presenting: UIViewController) -> Single<TTUser>
    func signOut() -> Single<Void>
}

final class AuthUseCaseImpl: AuthUseCase {
    var isLoggedIn: Observable<Bool> {
        let isLoggedIn = Auth.auth().currentUser != nil
        return .just(isLoggedIn)
    }
    
    private var clientId: String? {
        return FirebaseApp.app()?.options.clientID
    }
    
    func signInWithGoogle(presenting: UIViewController) -> Single<TTUser> {
        return _signInWithGoogle(presenting: presenting)
            .asObservable()
            .flatMapLatest(weakObj: self) { owner, credential -> Observable<TTUser> in
                owner._signInWithFirebase(with: credential)
                    .asObservable()
            }
            .asSingle()
    }
    
    func signOut() -> Single<Void> {
        .create { single in
            do {
                try Auth.auth().signOut()
                single(.success(()))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
}

private extension AuthUseCaseImpl {
    func _signInWithGoogle(presenting: UIViewController) -> Single<AuthCredential> {
        .create { [weak self] single in
            guard let clientId = self?.clientId else { return Disposables.create() }
            let config = GIDConfiguration(clientID: clientId)
            GIDSignIn.sharedInstance.signIn(with: config, presenting: presenting) { user, error in
                if let error = error {
                    single(.failure(error))
                }
                
                guard let authentication = user?.authentication,
                      let idToken = authentication.idToken else {
                    single(.failure(AuthError.invalidToken))
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
                
                single(.success(credential))
            }
            return Disposables.create()
        }
    }
    
    func _signInWithFirebase(with credential: AuthCredential) -> Single<TTUser> {
        .create { single in
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    single(.failure(error))
                }
                
                guard let user = result?.user else {
                    single(.failure(AuthError.userNotFound))
                    return
                }
                
                let ttUser = TTUser(id: user.uid,
                                    username: user.displayName.orEmpty,
                                    phoneNumber: user.phoneNumber.orEmpty,
                                    email: user.email.orEmpty,
                                    profileImage: (user.photoURL?.absoluteString).orEmpty)
                single(.success(ttUser))
            }
            return Disposables.create()
        }
    }
}
