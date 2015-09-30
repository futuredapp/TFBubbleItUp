//
//  TFTextField.swift
//  Pods
//
//  Created by Aleš Kocur on 30/09/15.
//
//

import UIKit

class TFTextField: UITextField {

    override func deleteBackward() {
        let shouldDismiss = self.text?.characters.count == 0
        
        super.deleteBackward()
        
        if shouldDismiss {
            self.delegate?.textField?(self, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: "")
        }
    }
}
