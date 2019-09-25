//
//  TransferenceDetailViewModelTests.swift
//  RxDojoTests
//
//  Created by Matheus Dutra on 23/09/19.
//  Copyright © 2019 Matheus Dutra. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift
import RxTest


@testable import RxDojo

final class TransferenceDetailViewModelTests: QuickSpec {
    
    // Properties
    
    var sut: TransferenceDetailViewModel!
    var rx_disposeBag: DisposeBag!
    var rx_scheduler: TestScheduler!
    var serviceStub: TransferenceDetailServiceStub!
    var routerStub: TransferenceDeitalRouterStub!
    var output: TransferenceDetailViewModel.Output!
    
    // Testable Observers
    
    var creditTextObserver: TestableObserver<String>!
    var invoiceTextObserver: TestableObserver<String>!
    var limitTextObserver: TestableObserver<String>!
    var loadingEvents: TestableObserver<Bool>!
    var errorEvents: TestableObserver<Error>!
    var routeToSucessScreen: TestableObserver<Void>!
    
    override func spec() {
        super.spec()
        
        describe("TransferenceDetailViewModelTests") {
            
            beforeEach {
                self.setup()
            }
            
            when("quando a view carregar (viewDidAppear) ") {
                
                then("então eventos de loading são emitidos") {
                    
                    expect(self.loadingEvents.events).to(equal([
                        
                        Recorded.next(10, true),
                        Recorded.next(10, false),
                    ]))
                }
                
                then("então uma request é feita") {
                    expect(self.routerStub.routeCalled).to(equal(true))
                }
                
                and("e quando a request retornar") {
                    
                    given("com sucesso") {
                        
                        then("então os textos são emitidos corretamente") {
                            
                            expect(self.limitTextObserver.events).to(equal([
                                Recorded.next(10, "Limite disponível\n\(CreditCard.dummy.limitValue)")
                            ]))
                            
                            expect(self.invoiceTextObserver.events).to(equal([
                                Recorded.next(10, "Fatura atual\n\(CreditCard.dummy.invoiceValue)")
                            ]))
                            
                            expect(self.creditTextObserver.events).to(equal([
                                Recorded.next(0, "Cartão de crédito"),
                                Recorded.completed(0)
                            ]))
                        }
                    }
                    
                    given("com erro") {
                        
                        beforeEach {
                            self.setup(service: TransferenceDetailServiceStub.init(result: .error))
                        }
                        
                        then("então eventos de erro são emitidos") {
                            expect(self.errorEvents.events.count).to(equal(2))
                        }
                    }
                }
            }
        }
    }
    
    func setup(service: TransferenceDetailServiceStub = TransferenceDetailServiceStub(), input: TransferenceDetailViewModel.Input? = nil) {
        
        self.routerStub = TransferenceDeitalRouterStub()
        self.serviceStub = service
        
        sut = TransferenceDetailViewModel(router: routerStub, service: service)
        rx_scheduler = TestScheduler(initialClock: 0)
        rx_disposeBag = DisposeBag()
        
        self.output = self.sut.transform(input: input ?? retrieveCustomInput())
        self.createTestableObservers(output: self.output)
        self.rx_scheduler.start()
    }
    
    func retrieveCustomInput() -> TransferenceDetailViewModel.Input {
        
        
        let viewDidLoad = rx_scheduler.createHotObservable([Recorded.next(10, ())]).asObservable()
        
        let payButtonTapped = rx_scheduler.createHotObservable([Recorded.next(10, ())]).asDriver(onErrorJustReturn: ())
        
        return TransferenceDetailViewModel.Input(viewDidLoad: viewDidLoad,
                                                 payButtonTapped: payButtonTapped)
    }
    
    func createTestableObservers(output: TransferenceDetailViewModel.Output) {
        
        creditTextObserver = rx_scheduler.createObserver(String.self)
        invoiceTextObserver = rx_scheduler.createObserver(String.self)
        limitTextObserver = rx_scheduler.createObserver(String.self)
        loadingEvents = rx_scheduler.createObserver(Bool.self)
        errorEvents = rx_scheduler.createObserver(Error.self)
        routeToSucessScreen = rx_scheduler.createObserver(Void.self)
        
        output.creditText.drive(creditTextObserver).disposed(by: rx_disposeBag)
        output.invoiceText.drive(invoiceTextObserver).disposed(by: rx_disposeBag)
        output.limitText.drive(limitTextObserver).disposed(by: rx_disposeBag)
        output.loadingEvents.drive(loadingEvents).disposed(by: rx_disposeBag)
        output.errorEvents.drive(errorEvents).disposed(by: rx_disposeBag)
        output.routeToSucessScreen.drive(routeToSucessScreen).disposed(by: rx_disposeBag)
    }
    
}

// MARK: - Stubs

final class TransferenceDetailServiceStub: TransferenceDetailServiceProtocol {
    
    enum Result {
        case success
        case error
    }
    
    let result: Result
    
    init(result: Result = .success) {
        self.result = result
    }
    
    func retrieveCreditCardData() -> Observable<CreditCard> {
        
        switch result {
        case .success:
            return Observable.just(CreditCard.dummy)
        case .error:
            return Observable.error(AppError.unknown)
        }
    }
}

final class TransferenceDeitalRouterStub: TransferenceDetailRoutering {
    
    var routeCalled = false
    
    func routeToSuccessScreen() {
        routeCalled = true
    }
}

// MARK: - Dummies

extension CreditCard {
    static var dummy: CreditCard {
        return CreditCard(invoiceValue: 100, limitValue: 200)
    }
}
