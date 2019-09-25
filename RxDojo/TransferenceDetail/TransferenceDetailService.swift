//
//  TransferenceDetailService.swift
//  RxDojo
//
//  Created by Matheus Dutra on 22/09/19.
//  Copyright © 2019 Matheus Dutra. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol TransferenceDetailServiceProtocol {
    func retrieveCreditCardData() -> Observable<CreditCard>
}

final class TransferenceDetailService: TransferenceDetailServiceProtocol {
    
    func retrieveCreditCardData() -> Observable<CreditCard> {
        return Observable.just(CreditCard(invoiceValue: 20, limitValue: 300))
    }
}
