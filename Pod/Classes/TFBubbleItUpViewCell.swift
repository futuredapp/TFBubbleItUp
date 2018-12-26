//
//  TFContactCollectionCellCollectionViewCell.swift
//  TFContactCollection
//
//  Created by Aleš Kocur on 12/09/15.
//  Copyright © 2015 The Funtasty. All rights reserved.
//

import UIKit

enum TFBubbleItUpViewCellMode {
    case Edit, View, Invalid
}

protocol TFBubbleItUpViewCellDelegate {
    func didChangeText(cell: TFBubbleItUpViewCell, text: String)
    func needUpdateLayout(cell: TFBubbleItUpViewCell)
    func createAndSwitchToNewCell(cell: TFBubbleItUpViewCell)
    func editingDidEnd(cell: TFBubbleItUpViewCell, text: String)
    func shouldDeleteCellInFrontOfCell(cell: TFBubbleItUpViewCell)
}

class TFBubbleItUpViewCell: UICollectionViewCell, UITextFieldDelegate {

    var textField: UITextField!
    
    var mode: TFBubbleItUpViewCellMode = .View
    var delegate: TFBubbleItUpViewCellDelegate?
    
    class var identifier: String {
        return "TFContactCollectionCellCollectionViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.clipsToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        self.layer.cornerRadius = 2.0
        self.layer.masksToBounds = true
        
        self.textField = TFTextField()
        
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.textField)
        
        
        // Setup constraints
        let views = ["field": self.textField]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[field]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(-4)-[field]-(-4)-|", options: NSLayoutFormatOptions(), metrics: nil, views: views)
        
        self.addConstraints(horizontalConstraints)
        self.addConstraints(verticalConstraints)
        
        self.textField.delegate = self
        
        self.textField.addTarget(self, action: #selector(TFBubbleItUpViewCell.editingChanged), for: .editingChanged)
        self.textField.addTarget(self, action: #selector(TFBubbleItUpViewCell.editingDidBegin), for: .editingDidBegin)
        self.textField.addTarget(self, action: #selector(TFBubbleItUpViewCell.editingDidEnd), for: .editingDidEnd)
        
        // Setup appearance
        self.textField.borderStyle = .none
        self.textField.textAlignment = .center
        self.textField.contentMode = .left
        self.textField.keyboardType = TFBubbleItUpViewConfiguration.keyboardType
        self.textField.returnKeyType = TFBubbleItUpViewConfiguration.returnKey
        self.textField.autocapitalizationType = TFBubbleItUpViewConfiguration.autoCapitalization
        self.textField.autocorrectionType = TFBubbleItUpViewConfiguration.autoCorrection
        
        self.setMode(.View)

    }
    
    func setMode(_ mode: TFBubbleItUpViewCellMode) {

        var m = mode
        
        if self.textField.text == "" { // If textfield is empty he should look like ready for editing
            m = .Edit
        }
        
        switch m {
        case .Edit:
            textField.backgroundColor = TFBubbleItUpViewConfiguration.editBackgroundColor
            textField.font = TFBubbleItUpViewConfiguration.editFont
            textField.textColor = TFBubbleItUpViewConfiguration.editFontColor
            self.backgroundColor = TFBubbleItUpViewConfiguration.editBackgroundColor
            self.layer.cornerRadius = CGFloat(TFBubbleItUpViewConfiguration.editCornerRadius)
        case .View:
            textField.backgroundColor = TFBubbleItUpViewConfiguration.viewBackgroundColor
            textField.font = TFBubbleItUpViewConfiguration.viewFont
            textField.textColor = TFBubbleItUpViewConfiguration.viewFontColor
            self.backgroundColor = TFBubbleItUpViewConfiguration.viewBackgroundColor
            self.layer.cornerRadius = CGFloat(TFBubbleItUpViewConfiguration.viewCornerRadius)
        case .Invalid:
            textField.backgroundColor = TFBubbleItUpViewConfiguration.invalidBackgroundColor
            textField.font = TFBubbleItUpViewConfiguration.invalidFont
            textField.textColor = TFBubbleItUpViewConfiguration.invalidFontColor
            self.backgroundColor = TFBubbleItUpViewConfiguration.invalidBackgroundColor
            self.layer.cornerRadius = CGFloat(TFBubbleItUpViewConfiguration.invalidCornerRadius)
        }
        
        self.mode = mode
    }
    
    override var intrinsicContentSize: CGSize {
        var textFieldSize = self.textField.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                               height: self.textField.bounds.height))
        textFieldSize.width += 30
        
        return textFieldSize
    }
    
    override func becomeFirstResponder() -> Bool {
        
        self.textField.becomeFirstResponder()
        self.setMode(.Edit)
        
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        self.textField.resignFirstResponder()
        return true
    }
    
    func configure(with item: TFBubbleItem) {
        self.textField.text = item.text
        self.setMode(TFBubbleItUpValidation.isValid(text: textField.text) ? .View : .Invalid)
    }
    
    // MARK:- UITextField delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == " " && TFBubbleItUpViewConfiguration.skipOnWhitespace && TFBubbleItUpValidation.isValid(text: self.textField.text) {
            self.delegate?.createAndSwitchToNewCell(cell: self)
            
        } else if string == " " && TFBubbleItUpViewConfiguration.skipOnWhitespace {
            
        } else if string == "" && textField.text == "" {
            self.delegate?.shouldDeleteCellInFrontOfCell(cell: self)
            
        } else {
            return self.mode == .Edit
        }
        
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (TFBubbleItUpViewConfiguration.skipOnReturnKey) {
            
            if !TFBubbleItUpValidation.isValid(text: textField.text) {
                
                return false
            } else {
                self.delegate?.createAndSwitchToNewCell(cell: self)
            }
        } else {
            self.textField.resignFirstResponder()
        }
        
        return false
    }
    
    // MARK:- UITextField handlers
    
    func editingChanged(textField: UITextField) {
        self.delegate?.didChangeText(cell: self, text: textField.text ?? "")
        self.delegate?.needUpdateLayout(cell: self)
    }
    
    func editingDidBegin(textField: UITextField) {
        self.setMode(.Edit)
    }
    
    func editingDidEnd(textField: UITextField) {
        
        self.setMode(TFBubbleItUpValidation.isValid(text: textField.text) ? .View : .Invalid)
        
        self.delegate?.editingDidEnd(cell: self, text: textField.text ?? "")
    }
    
    
    
}
