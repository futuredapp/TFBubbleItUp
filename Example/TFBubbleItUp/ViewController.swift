//
//  ViewController.swift
//  TFBubbleItUp
//
//  Created by Ales Kocur on 09/13/2015.
//  Copyright (c) 2015 Ales Kocur. All rights reserved.
//

import TFBubbleItUp
import UIKit

class ViewController: UIViewController, TFBubbleItUpViewDelegate {

    @IBOutlet var bubbleItUpView: TFBubbleItUpView!
    @IBOutlet var textLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.textLabel.text = "There will be shown added items"

        // Set bubbleItUpDelegate delegate
        self.bubbleItUpView.bubbleItUpDelegate = self
        self.bubbleItUpView.setPlaceholderText(text: "Type something...")

        let validation = TFBubbleItUpValidation.testEmptiness() |>> TFBubbleItUpValidation.testEmailAddress()
        TFBubbleItUpViewConfiguration.itemValidation = validation

        TFBubbleItUpViewConfiguration.numberOfItems = .Quantity(5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addAnother(_ sender: Any) {
        _ = self.bubbleItUpView.addStringItem(text: "ales@thefuntasty.com")
    }

    @IBAction func removeLast(_ sender: Any) {
        _ = self.bubbleItUpView.removeStringItem(text: "ales@thefuntasty.com")
    }
    // MARK: - TFBubbleItUpDelegate

    func bubbleItUpViewDidFinishEditingBubble(view: TFBubbleItUpView, text: String) {
        self.textLabel.text = view.validStrings().joined(separator: ", ")
    }
}
