import Foundation
import UIKit

public enum NumberOfItems {
    case Unlimited
    case Quantity(Int)
}

public class TFBubbleItUpViewConfiguration {
    
    /// Background color for cell in normal state
    public static var viewBackgroundColor: UIColor = UIColor(red: 0.918, green: 0.933, blue: 0.949, alpha: 1.00)
    
    /// Background color for cell in edit state
    public static var editBackgroundColor: UIColor = .white
    
    /// Background color for cell in invalid state
    public static var invalidBackgroundColor: UIColor = .white
    
    /// Font for cell in normal state
    public static var viewFont: UIFont = .systemFont(ofSize: 12.0)
    
    /// Font for cell in normal state
    public static var placeholderFont: UIFont = .systemFont(ofSize: 12.0)
    
    /// Font for cell in edit state
    public static var editFont: UIFont = .systemFont(ofSize: 12.0)
    
    /// Font for cell in invalid state
    public static var invalidFont: UIFont = .systemFont(ofSize: 12.0)
    
    /// Font color for cell in view state
    public static var viewFontColor: UIColor = UIColor(red: 0.353, green: 0.388, blue: 0.431, alpha: 1.00)
    
    /// Font color for cell in edit state
    public static var editFontColor: UIColor = UIColor(red: 0.510, green: 0.553, blue: 0.596, alpha: 1.00)

    /// Font color for cell in invalid state
    public static var invalidFontColor: UIColor = UIColor(red: 0.510, green: 0.553, blue: 0.596, alpha: 1.00)
    
    /// Font color for cell in invalid state
    public static var placeholderFontColor: UIColor = UIColor(red: 0.510, green: 0.553, blue: 0.596, alpha: 1.00)
    
    /// Corner radius for cell in view state
    public static var viewCornerRadius: Float = 2.0
    
    /// Corner radius for cell in edit state
    public static var editCornerRadius: Float = 2.0

    /// Corner radius for cell in invalid state
    public static var invalidCornerRadius: Float = 2.0

    /// Height for item
    public static var cellHeight: Float = 25.0
    
    /// View insets
    public static var inset: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    /// Interitem spacing
    public static var interitemSpacing: CGFloat = 5.0
    
    /// Line spacing
    public static var lineSpacing: CGFloat = 5.0
    
    /// Keyboard type
    public static var keyboardType: UIKeyboardType = .emailAddress
    
    /// Keyboard return key
    public static var returnKey: UIReturnKeyType = .done
    
    /// Field auto-capitalization type
    public static var autoCapitalization: UITextAutocapitalizationType = .none
    
    /// Field auto-correction type
    public static var autoCorrection: UITextAutocorrectionType = .no
    
    /// If true it creates new item when user types whitespace
    public static var skipOnWhitespace: Bool = true
    
    /// If true it creates new item when user press the keyboards return key. Otherwise resigns first responder
    public static var skipOnReturnKey: Bool = false
    
    /// Number of items that could be written
    public static var numberOfItems: NumberOfItems = .Unlimited
    
    /// Item has to pass validation before it can be bubbled
    public static var itemValidation: Validation? = nil
    
}
