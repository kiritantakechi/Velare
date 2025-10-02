//
//  MetalViewModel.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import SwiftUI

@Observable
final class MetalViewModel {
    private let cacheService: CacheService
    
    var device: MTLDevice! { cacheService.device }

    init(cacheService: CacheService) {
        self.cacheService = cacheService
    }
}
