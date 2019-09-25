//
//  TransferenceDetailRouter.swift
//  RxDojo
//
//  Created by Matheus Dutra on 22/09/19.
//  Copyright © 2019 Matheus Dutra. All rights reserved.
//

import Foundation

protocol TransferenceDetailRoutering {
    func routeToSuccessScreen()
}

final class TransferenceDetailRouter: TransferenceDetailRoutering {
    
    func routeToSuccessScreen() {
        print("Route to somewhere..")
    }
}
