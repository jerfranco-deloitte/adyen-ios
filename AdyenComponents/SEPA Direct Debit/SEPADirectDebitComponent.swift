//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for SEPA Direct Debit payments.
public final class SEPADirectDebitComponent: PaymentComponent, PresentableComponent, LoadingComponent {
    
    /// Configuration for SEPA Direct Debit Component
    public typealias Configuration = BasicComponentConfiguration
    
    /// :nodoc:
    /// The context object for this component.
    public let context: AdyenContext
    
    /// Component's configuration
    public var configuration: Configuration
    
    /// The SEPA Direct Debit payment method.
    public var paymentMethod: PaymentMethod {
        sepaDirectDebitPaymentMethod
    }
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// Initializes the SEPA Direct Debit component.
    ///
    /// - Parameter paymentMethod: The SEPA Direct Debit payment method.
    /// - Parameter context: The Adyen context.
    /// - Parameter configuration: Configuration for the component.
    public init(paymentMethod: SEPADirectDebitPaymentMethod,
                context: AdyenContext,
                configuration: Configuration = .init()) {
        self.sepaDirectDebitPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }
    
    private let sepaDirectDebitPaymentMethod: SEPADirectDebitPaymentMethod
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController,
                                                                             style: configuration.style)
    
    /// :nodoc:
    public var requiresModalPresentation: Bool = true
    
    /// :nodoc:
    public func stopLoading() {
        button.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }
    
    // MARK: - View Controller
    
    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: configuration.style)
        formViewController.localizationParameters = configuration.localizationParameters
        formViewController.delegate = self

        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
        formViewController.append(nameItem)
        formViewController.append(ibanItem)
        formViewController.append(button)

        return formViewController
    }()
    
    // MARK: - Private
    
    private func didSelectSubmitButton() {
        guard formViewController.validate() else {
            return
        }
        
        let details = SEPADirectDebitDetails(paymentMethod: sepaDirectDebitPaymentMethod,
                                             iban: ibanItem.value,
                                             ownerName: nameItem.value)
        button.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false
        
        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: amountToPay, order: order))
    }
    
    // MARK: - Form Items
    
    internal lazy var nameItem: FormTextInputItem = {
        let nameItem = FormTextInputItem(style: configuration.style.textField)
        nameItem.title = localizedString(.sepaNameItemTitle, configuration.localizationParameters)
        nameItem.placeholder = localizedString(.sepaNameItemPlaceholder, configuration.localizationParameters)
        nameItem.validator = LengthValidator(minimumLength: 2)
        nameItem.validationFailureMessage = localizedString(.sepaNameItemInvalid, configuration.localizationParameters)
        nameItem.autocapitalizationType = .words
        nameItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "nameItem")
        return nameItem
    }()
    
    internal lazy var ibanItem: FormTextInputItem = {
        func localizedPlaceholder() -> String {
            let countryCode = Locale.current.regionCode
            let specification = countryCode.flatMap(IBANSpecification.init(forCountryCode:))
            let example = specification?.example ?? "NL26INGB0336169116"
            
            return IBANFormatter().formattedValue(for: example)
        }
        
        let ibanItem = FormTextInputItem(style: configuration.style.textField)
        ibanItem.title = localizedString(.sepaIbanItemTitle, configuration.localizationParameters)
        ibanItem.placeholder = localizedPlaceholder()
        ibanItem.formatter = IBANFormatter()
        ibanItem.validator = IBANValidator()
        ibanItem.validationFailureMessage = localizedString(.sepaIbanItemInvalid, configuration.localizationParameters)
        ibanItem.autocapitalizationType = .allCharacters
        ibanItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "ibanItem")
        return ibanItem
    }()

    internal lazy var button: FormButtonItem = {
        let item = FormButtonItem(style: configuration.style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "payButtonItem")
        item.title = localizedSubmitButtonTitle(with: payment?.amount,
                                                style: .immediate,
                                                configuration.localizationParameters)
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()

}

extension SEPADirectDebitComponent: TrackableComponent {}

/// :nodoc:
extension SEPADirectDebitComponent: ViewControllerDelegate {

    public func viewWillAppear(viewController: UIViewController) {
        sendTelemetryEvent()
    }
}
