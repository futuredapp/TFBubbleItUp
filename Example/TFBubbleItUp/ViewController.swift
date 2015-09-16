//
//  ViewController.swift
//  TFBubbleItUp
//
//  Created by Ales Kocur on 09/13/2015.
//  Copyright (c) 2015 Ales Kocur. All rights reserved.
//

import UIKit
import TFBubbleItUp

class ViewController: UIViewController, TFBubbleItUpViewDelegate {

    @IBOutlet var bubbleItUpView: TFBubbleItUpView!
    @IBOutlet var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.textLabel.text = "There will be shown added items"
        
        // Set bubbleItUpDelegate delegate
        self.bubbleItUpView.bubbleItUpDelegate = self
        
        let validation = TFBubbleItUpValidation.testEmptiness() |>> TFBubbleItUpValidation.testEmailAddress()
        TFBubbleItUpViewConfiguration.itemValidation = validation
        
        TFBubbleItUpViewConfiguration.numberOfItems = .Quantity(5)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:- TFBubbleItUpDelegate
    
    func bubbleItUpViewDidFinishEditingBubble(view: TFBubbleItUpView, text: String) {
        self.textLabel.text = view.validStrings().joinWithSeparator(", ")
    }
    
}

