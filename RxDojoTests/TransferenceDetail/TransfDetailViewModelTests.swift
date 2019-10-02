//
//  TransfDetailViewModelTests.swift
//  RxDojoTests
//
//  Created by Matheus Dutra on 01/10/19.
//  Copyright © 2019 Matheus Dutra. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxTest
import RxSwift

@testable import RxDojo

class TransfDetailViewModelTests: QuickSpec {
    
    var sut: TransferenceDetailViewModel!
    var routerStub: TransferenceDetailsRouterStub!
    var serviceStub: TransferDetailsServiceStub!
    var rx_scheduler: TestScheduler!
    var rx_disposeBag: DisposeBag!
    
    var creditTextTestable: TestableObserver<String>!
    var invoiceTextTestable: TestableObserver<String>!
    var limitTextTestable: TestableObserver<String>!
    var loadingEventsTestable: TestableObserver<Bool>!
    var errorEventsTestable: TestableObserver<Error>!
    var routeToSucessScreenTestable: TestableObserver<Void>!
    
    func createInput() -> TransferenceDetailViewModel.Input {
        let didLoadSimulation = rx_scheduler.createHotObservable(
            [Recorded.next(10, ())]
        )
        
        let payButtonSimulation = rx_scheduler.createHotObservable(
            [Recorded.next(11, ())]
        )
        
        return .init(
            viewDidLoad: didLoadSimulation.asObservable(),
            payButtonTapped: payButtonSimulation.asDriver(onErrorJustReturn: ())
        )
    }
    
    func bindOutput(output: TransferenceDetailViewModel.Output) {
        creditTextTestable = rx_scheduler.createObserver(String.self)
        invoiceTextTestable = rx_scheduler.createObserver(String.self)
        limitTextTestable = rx_scheduler.createObserver(String.self)
        loadingEventsTestable = rx_scheduler.createObserver(Bool.self)
        errorEventsTestable = rx_scheduler.createObserver(Error.self)
        routeToSucessScreenTestable = rx_scheduler.createObserver(Void.self)
        
        output.creditText.drive(creditTextTestable).disposed(by: rx_disposeBag)
        output.invoiceText.drive(invoiceTextTestable).disposed(by: rx_disposeBag)
        output.limitText.drive(limitTextTestable).disposed(by: rx_disposeBag)
        output.loadingEvents.drive(loadingEventsTestable).disposed(by: rx_disposeBag)
        output.errorEvents.drive(errorEventsTestable).disposed(by: rx_disposeBag)
        output.routeToSucessScreen.drive(routeToSucessScreenTestable).disposed(by: rx_disposeBag)
    }
    
    func setup(resultService: TransferDetailsServiceStub.ResultService = .success(CreditCard.dami)) {
        
        rx_disposeBag = DisposeBag()
        rx_scheduler = TestScheduler(initialClock: 0)
        
        routerStub = TransferenceDetailsRouterStub()
        serviceStub = TransferDetailsServiceStub(result: resultService)
        
        let input = createInput()
        
        sut = TransferenceDetailViewModel(router: routerStub, service: serviceStub)
        bindOutput(output: sut.transform(input: input))
        
        rx_scheduler.start()
    }
    
    override func spec() {
        super.spec()
        
        given("TransfDetailViewModelTest") {
            
            when("quando a view é carregada (viewDidLoad)") {
                
                beforeEach {
                    self.setup()
                }
                then("então o serviço é chamado") {
                    expect(self.serviceStub.serviceCalled).to(equal(true))
                }
                
                and("e o serviço retornar") {
                    given("com sucesso") {
                        then("então a label crédito é preenchida corretamente") { expect(self.creditTextTestable.events.first!.value.element).to(equal("Cartão de crédito"))
                        }
                        
                        then("então a label fatura é preenchida corretamente") {
                            expect(self.invoiceTextTestable.events).to(equal([ Recorded.next(10, "Fatura atual\n-1.0")]))
                        }
                        
                        then("então a label limite é preenchida corretamente") {
                            
                        }
                    }
                    
                    given("com erro") {
                        then("então o evento de erro deve ser emitido") {
                            
                        }
                    }
                }
            }
            
            when("quando o usuário clicar no botão de pagar") {
                then("então o metódo de pagar é chamado"){
                    
                }
            }
        }
    }
}

class TransferenceDetailsRouterStub: TransferenceDetailRoutering {
    var routerCalled = false
    
    func routeToSuccessScreen() {
        routerCalled = true
    }
}

class TransferDetailsServiceStub: TransferenceDetailServiceProtocol {
    
    enum ResultService {
    case success(CreditCard)
    case failure(Error)
    }
    
    let result: ResultService
    
    var serviceCalled = false
    
    init(result: ResultService) {
        self.result = result
    }
    
    func retrieveCreditCardData() -> Observable<CreditCard> {
        serviceCalled = true
        
        switch result {
        case .success(let card):
            return Observable.just(card)
        case .failure(let error):
            return Observable.error(error)
        }
    }
}

extension CreditCard {
    
    static var dami: CreditCard {
        return CreditCard(invoiceValue: -1, limitValue: -1)
    }
}
