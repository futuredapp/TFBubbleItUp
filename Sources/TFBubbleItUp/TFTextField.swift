import UIKit

class TFTextField: UITextField {

    override func deleteBackward() {
        let shouldDismiss = self.text?.count == 0

        super.deleteBackward()

        if shouldDismiss {
            _ = self.delegate?.textField?(self, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "")
        }
    }
}
