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
//        registerConfigService()
//        registerNetworkService()
//        registerEventsRepo()
    }
}

extension Resolver {
//    // Inject server config
//    private static func registerConfigService() {
//        register { ServerConfig.testing as ServerConfigType }
//            .scope(.cached)
//    }
//
//    // Inject NetworkPlatform
//    private static func registerNetworkService() {
//        // Register UseCaseProvider
//        register {
//            FTNetworkPlatform.UseCaseProviderImpl(
//                config: resolve() as ServerConfigType
//            )  as FTNetworkPlatform.UseCaseProvider
//        }
//        .scope(.cached)
//
//        // Register EventUseCase
//        register { () -> FTNetworkPlatform.EventUseCase in
//            let network = resolve() as FTNetworkPlatform.UseCaseProvider
//
//            return network.makeEventUseCase()
//        }
//        .scope(.cached)
//    }
//
//    // Register EventsRepo
//    private static func registerEventsRepo() {
//        register {
//            EventsRepoImpl() as EventsRepo
//        }.scope(.cached)
//    }
}

// MARK: Utils
//extension FTNetworkPlatform.UseCaseProviderImpl {
//    convenience init(config: ServerConfigType) {
//        self.init(config: BuildConfig(baseURL: config.serverUrl,
//                                      detailURL: config.detailURL))
//    }
//}
