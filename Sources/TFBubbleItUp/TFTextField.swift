import UIKit

class TFTextField: UITextField {

    override func deleteBackward() {
        let shouldDismiss = self.text?.count == 0
        
        super.deleteBackward()
        
        if shouldDismiss {
            _ = self.delegate?.textField?(self, shouldChangeCharactersIn: NSMakeRange(0, 0), replacementString: "")
        }
    }
}
