//
//  Resolver.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import Resolver

extension Resolver: ResolverRegistering {
    // Inject all services
    public static func registerAllServices() {
        registerAuthService()
        registerKeyValueStoreService()
        registerUserRepo()
    }
}

extension Resolver {
    private static func registerAuthService() {
        register {
            AuthUseCaseImpl() as AuthUseCase
        }
        .scope(.cached)
    }
    
    private static func registerKeyValueStoreService() {
        register {
            UserDefaults.instance() as KeyValueStoreType
        }
        .scope(.cached)
    }
    
    private static func registerUserRepo() {
        register {
            UserRepoImpl() as UserRepo
        }
        .scope(.cached)
    }
}
