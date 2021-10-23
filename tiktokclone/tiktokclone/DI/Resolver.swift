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
        registerVideoThumbnailGenerator()
        registerStorageUseCase()
        registerVideoUseCase()
        registerCommentUseCase()
        registerUserRepo()
        registerVideoRepo()
        registerCommentRepo()
        registerTimeFormatter()
    }
    
    public static func registerMockServices() {
        registerMockVideoRepo()
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
    
    private static func registerVideoThumbnailGenerator() {
        register {
            VideoThumbnailGeneratorImpl() as VideoThumbnailGenerator
        }
        .scope(.cached)
    }
    
    private static func registerStorageUseCase() {
        register {
            StorageUseCaseImpl() as StorageUseCase
        }
        .scope(.cached)
    }
    
    private static func registerVideoUseCase() {
        register {
            VideoUseCaseImpl() as VideoUseCase
        }
        .scope(.cached)
    }
    
    private static func registerVideoRepo() {
        register {
            VideoRepoImpl() as VideoRepo
        }
        .scope(.cached)
    }
    
    private static func registerCommentUseCase() {
        register {
            CommentUseCaseImpl() as CommentUseCase
        }
        .scope(.cached)
    }
    
    private static func registerCommentRepo() {
        register {
            CommentRepoImpl() as CommentRepo
        }
        .scope(.cached)
    }
    
    private static func registerTimeFormatter() {
        register {
            TimeFormaterImpl() as TimeFormatter
        }
        .scope(.cached)
    }
}

extension Resolver {
    private static func registerMockVideoRepo() {
        register {
            VideoRepoMock() as VideoRepo
        }
        .scope(.unique)
    }
}
