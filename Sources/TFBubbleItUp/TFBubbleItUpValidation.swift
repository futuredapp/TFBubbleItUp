import Foundation

public typealias Validation = (String) -> Bool

precedencegroup DefaultPrecedence {
    associativity: left
}
infix operator |>> : DefaultPrecedence

public func |>> (v1: @escaping Validation, v2: @escaping Validation) -> Validation {
    return { text in return v1(text) && v2(text) }
}

public class TFBubbleItUpValidation {

    /// Validates if text is not empty (empty string is not valid)
    public class func testEmptiness() -> Validation {
        return { text in
            return text != ""
        }
    }

    /// Validates if text is an email address 
    public class func testEmailAddress() -> Validation {
        return { text in
            let emailRegex = "^[+\\w\\.\\-']+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*(\\.[a-zA-Z]{2,})+$"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            return emailTest.evaluate(with: text)
        }
    }

    public class func combine(v1: @escaping Validation, v2: @escaping Validation) -> Validation {
        return { text in return v1(text) && v2(text) }
    }

    class func isValid(text: String?) -> Bool {

        if let t = text, let validation = TFBubbleItUpViewConfiguration.itemValidation {
            return validation(t)
        } else {
            return true
        }
    }
}
