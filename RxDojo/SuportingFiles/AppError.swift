//
//  AppError.swift
//  Events
//
//  Created by Matheus Dutra on 07/07/19.
//  Copyright © 2019 Matheus Dutra. All rights reserved.
//

import Foundation

struct AppError {
    static var unknown: NSError {
        return NSError(custom: "Ops! Um problema inesperado aconteceu.")
    }
    
    static var mainThread: NSError {
        return NSError(custom: "Execução não permitida na main thread.")
    }
    
    static var unknownServerData: NSError {
        return NSError(custom: "Não foi possivel interpretar os dados recebidos do servidor.")
    }
    static var unableToDecode: NSError {
        return NSError(custom: "Failed to decode JSON data.")
    }
}

extension NSError {
    convenience init(custom: String) {
        self.init(domain: custom, code: 0, userInfo: [NSLocalizedDescriptionKey:custom])
    }
}
