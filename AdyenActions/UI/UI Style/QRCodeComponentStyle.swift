//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// Contains the styling customization options for the QR code component.
public struct QRCodeComponentStyle: ViewStyle {
    
    /// The copy button style.
    public var copyCodeButton = ButtonStyle(
        title: TextStyle(font: .preferredFont(forTextStyle: .headline), color: .white),
        cornerRadius: 8,
        background: UIColor.Adyen.defaultBlue
    )

    /// The save as image button style.
    public var saveAsImageButton = ButtonStyle(
        title: TextStyle(font: .preferredFont(forTextStyle: .headline), color: .white),
        cornerRadius: 8,
        background: UIColor.Adyen.defaultBlue
    )
    
    /// The instruction label style.
    public var instructionLabel = TextStyle(font: .preferredFont(forTextStyle: .subheadline), color: UIColor.Adyen.componentLabel)
    
    /// The amount to pay label style.
    public var amountToPayLabel = TextStyle(font: .preferredFont(forTextStyle: .subheadline), color: UIColor.Adyen.componentLabel)

    /// The progress view style.
    public var progressView = ProgressViewStyle(
        progressTintColor: UIColor.Adyen.defaultBlue,
        trackTintColor: UIColor.Adyen.lightGray
    )
    
    /// The expiration label style.
    public var expirationLabel = TextStyle(font: .preferredFont(forTextStyle: .footnote), color: UIColor.Adyen.componentSecondaryLabel)
    
    /// The corner rounding for the logo
    public var logoCornerRounding: CornerRounding = .fixed(5)
        
    public var backgroundColor = UIColor.Adyen.componentBackground
    
    /// Initializes the QR code component style with the default style
    public init() {}
}
