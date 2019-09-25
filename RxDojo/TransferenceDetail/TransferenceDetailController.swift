//
//  TransferenceDetailController.swift
//  RxDojo
//
//  Created by Matheus Dutra on 22/09/19.
//  Copyright © 2019 Matheus Dutra. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TransferenceDetailController: UIViewController {
    
    private let viewModel = TransferenceDetailViewModel()
    
    private let disposeBag = DisposeBag()
    
    private let clientNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private let invoiceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .red
        return label
    }()
    
    private let limitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
        return label
    }()
    
    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [clientNameLabel, invoiceLabel, limitLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.backgroundColor = .white
        return stack
    }()
    
    private let customView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        view.layer.borderWidth = 0.5
        view.layer.shadowOpacity = 0.3
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowRadius = 10
        return view
    }()
    
    private let payInvoiceButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Pagar", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    private lazy var viewDidLoadObservable : Observable<Void> = {
        return self.rx.sentMessage(#selector(UIViewController.viewDidAppear(_:))).mapTo(())
    }()
    
    private lazy var payButtonObservable: Driver<Void> = {
        return payInvoiceButton.rx.tap.asDriver()
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupSubviews()
        setupConstraints()
        createBinds(output: makeViewModelOutput())
    }
    
    func makeViewModelOutput() -> TransferenceDetailViewModel.Output {
        
        let input = TransferenceDetailViewModel.Input(viewDidLoad: viewDidLoadObservable,
                                                             payButtonTapped: payButtonObservable)
               
        let output = viewModel.transform(input: input)
        
        return output
    }
    
    func createBinds(output: TransferenceDetailViewModel.Output) {
   
        output.creditText
            .drive(clientNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.invoiceText
            .drive(invoiceLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.limitText
            .drive(limitLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.routeToSucessScreen
               .drive()
               .disposed(by: disposeBag)
        
        output.errorEvents
            .drive(onNext: { [weak self] (error) in
                self?.payInvoiceButton.isHidden = true
                self?.showAlert(message: error.localizedDescription)
        }).disposed(by: disposeBag)
        
        output.loadingEvents
             .drive(onNext: { [weak self] (isloading) in
                 self?.customView.alpha = isloading ? 0 : 1
             }).disposed(by: disposeBag)
    }
    
    func setupSubviews() {
        
        view.backgroundColor = .white
        
        view.addSubview(customView)
        view.addSubview(payInvoiceButton)
        customView.addSubview(labelsStack)
    }
    
    func setupConstraints() {
        
        customView.translatesAutoresizingMaskIntoConstraints = false
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        payInvoiceButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            customView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            labelsStack.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 30),
            labelsStack.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant:  -30),
            labelsStack.topAnchor.constraint(equalTo: customView.topAnchor, constant: 30),
            labelsStack.bottomAnchor.constraint(equalTo: customView.bottomAnchor, constant:  -30),
            
            payInvoiceButton.topAnchor.constraint(equalTo: customView.bottomAnchor, constant: 40),
            payInvoiceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            payInvoiceButton.widthAnchor.constraint(equalTo: customView.widthAnchor)
            ])
    }
}

extension UIViewController {
    
    func showAlert(message: String) {
        
        let alert = UIAlertController(title: "OPS!",
                                      message: message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
