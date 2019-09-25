//
//  TransferenceDetailViewModel.swift
//  RxDojo
//
//  Created by Matheus Dutra on 22/09/19.
//  Copyright © 2019 Matheus Dutra. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt

final class TransferenceDetailViewModel {
    
    private let router: TransferenceDetailRoutering
    private let service: TransferenceDetailServiceProtocol
    
    init(router: TransferenceDetailRoutering = TransferenceDetailRouter(),
         service: TransferenceDetailServiceProtocol = TransferenceDetailService()) {
        
        self.router = router
        self.service = service
    }
    
    func transform(input: Input) -> Output {
        
        let loaderPublisher = PublishSubject<Bool>()
        let loaderObservable = loaderPublisher.asDriver(onErrorJustReturn: false)
        
        let event = retrieveCreditEvent(input: input, loaderPublisher: loaderPublisher).share()
        
        let creditText = Driver.just("Cartão de crédito")
        let invoiceText = retrieveInvoiceLabelText(event: event)
        let limitText = retrieveLimitLabelText(event: event)
        
        let errors = retrieveErrors(event: event)
        
        let routeAction = retrieveRouteAction(input: input)
        
        return Output(creditText: creditText,
                      invoiceText: invoiceText,
                      limitText: limitText,
                      loadingEvents: loaderObservable,
                      errorEvents: errors,
                      routeToSucessScreen: routeAction)
    }
    
    private func retrieveCreditEvent(input: Input, loaderPublisher: PublishSubject<Bool>) -> Observable<Event<CreditCard>> {
        
        return  input
            .viewDidLoad
            .flatMapLatest { _ in self.retrieveCreditInformation(loadingPublisher: loaderPublisher)}
            .materialize()
    }
    
    private func retrieveLimitLabelText(event: Observable<Event<CreditCard>>) -> Driver<String> {
        
        return event
            .elements()
            .map { "Limite disponível\n\($0.limitValue)"}
            .asDriver(onErrorJustReturn: "")
    }
    
    private func retrieveInvoiceLabelText(event: Observable<Event<CreditCard>>) -> Driver<String> {
        
        return event
            .elements()
            .map { "Fatura atual\n\($0.invoiceValue)"}
            .asDriver(onErrorJustReturn: "")
    }
    
    private func retrieveErrors(event: Observable<Event<CreditCard>>) -> Driver<Error> {
        
        return  event
            .errors()
            .asDriver(onErrorJustReturn: NSError(custom: ""))
    }
    
    private func retrieveCreditInformation(loadingPublisher: PublishSubject<Bool>) -> Observable<CreditCard> {
        
        return service.retrieveCreditCardData()
            .do(onSubscribe: {
                loadingPublisher.onNext(true)
            }, onDispose: {
                loadingPublisher.onNext(false)
            })
    }
    
    private func retrieveRouteAction(input: Input) -> Driver<Void> {
        
        return input.payButtonTapped
            .do(onNext: { [router] in router.routeToSuccessScreen() })
            .asDriver(onErrorJustReturn: ())
    }
    
}

// MARK: - Models

extension TransferenceDetailViewModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let payButtonTapped: Driver<Void>
    }
    
    struct Output {
        let creditText: Driver<String>
        let invoiceText: Driver<String>
        let limitText: Driver<String>
        let loadingEvents: Driver<Bool>
        let errorEvents: Driver<Error>
        let routeToSucessScreen: Driver<Void>
    }
}
