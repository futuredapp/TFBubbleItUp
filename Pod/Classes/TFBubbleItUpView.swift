//
//  TFContactCollection.swift
//  TFContactCollection
//
//  Created by Aleš Kocur on 12/09/15.
//  Copyright © 2015 The Funtasty. All rights reserved.
//

import UIKit

public struct TFBubbleItem {
    var text: String
    var becomeFirstResponder: Bool = false
    
    init(text: String, becomeFirstResponder: Bool = false) {
        self.text = text
        self.becomeFirstResponder = becomeFirstResponder
    }
}

@objc public protocol TFBubbleItUpViewDelegate {
    func bubbleItUpViewDidFinishEditingBubble(view: TFBubbleItUpView, text: String)
}

@IBDesignable public class TFBubbleItUpView: UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate, TFBubbleItUpViewCellDelegate {

    private var items: [TFBubbleItem] = []
    private var sizingCell: TFBubbleItUpViewCell!
    private var tapRecognizer: UITapGestureRecognizer!
    private var placeholderLabel: UILabel!
    
    public var bubbleItUpDelegate: TFBubbleItUpViewDelegate?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.collectionViewLayout = TFBubbleItUpViewFlowLayout()
        self.customInit()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: TFBubbleItUpViewFlowLayout())
        self.customInit()
        
    }
    
    func customInit() {
        // Load sizing cell for width calculation
        self.sizingCell = TFBubbleItUpViewCell(frame: CGRectMake(0, 0, 100, CGFloat(TFBubbleItUpViewConfiguration.cellHeight)))

        self.backgroundColor = UIColor.whiteColor()
        var frame = self.bounds
        frame.size.height = self.minimumHeight()
        self.placeholderLabel = UILabel(frame: CGRectInset(frame, 20, 0))
        let view = UIView(frame: frame)
        view.addSubview(self.placeholderLabel)
        self.backgroundView = view
        self.placeholderLabel.font = TFBubbleItUpViewConfiguration.placeholderFont
        self.placeholderLabel.textColor = TFBubbleItUpViewConfiguration.placeholderFontColor
        
        self.registerClass(TFBubbleItUpViewCell.self, forCellWithReuseIdentifier: TFBubbleItUpViewCell.identifier)
        
        self.dataSource = self
        self.delegate = self
        
        if let layout = self.collectionViewLayout as? TFBubbleItUpViewFlowLayout {
            layout.sectionInset = TFBubbleItUpViewConfiguration.inset
            layout.minimumInteritemSpacing = TFBubbleItUpViewConfiguration.interitemSpacing
            layout.minimumLineSpacing = TFBubbleItUpViewConfiguration.lineSpacing
        }
        
        self.tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("didTapOnView:"))
        self.addGestureRecognizer(self.tapRecognizer)
    }
    
    public override func prepareForInterfaceBuilder() {
        self.setItems([TFBubbleItem(text: "exm@ex.com"), TFBubbleItem(text: "hello@thefuntasty.com")])
    }
    
    // MARK:- Public API
    
    /// Sets new items and reloads sizes
    func setItems(items: [TFBubbleItem]) {
        self.items = items // Set new items
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.collectionViewLayout.invalidateLayout() // Invalidate layout
            self.invalidateIntrinsicContentSize(nil) // Invalidate intrinsic size
        }
        
        self.reloadData() // Reload collectionView
        
        CATransaction.commit()
    }
    
    /// Returns all non-empty items
    public func stringItems() -> [String] {
        
        var stringArray: [String] = []
        
        for item in self.items {
            if item.text != "" {
                stringArray.append(item.text)
            }
        }
        
        return stringArray
    }
    
    /// Returns all valid strings
    public func validStrings() -> [String] {
        var stringArray: [String] = []
        
        for item in self.items {
            if item.text != "" && TFBubbleItUpValidation.isValid(item.text) {
                stringArray.append(item.text)
            }
        }
        
        return stringArray
    }
    
    public func setPlaceholderText(text: String) {
        self.placeholderLabel.text = text
    }
    
    // MARK:- Autolayout
    
    override public func intrinsicContentSize() -> CGSize {
        // Calculate custom intrinsic size by collectionViewLayouts contentent size
        let size = (self.collectionViewLayout as! UICollectionViewFlowLayout).collectionViewContentSize()
        
        return CGSizeMake(CGRectGetWidth(self.bounds), max(self.minimumHeight(), size.height))
    }
    
    func minimumHeight() -> CGFloat {
        let defaultHeight: CGFloat = CGFloat(TFBubbleItUpViewConfiguration.cellHeight)
        let padding = TFBubbleItUpViewConfiguration.inset.top + TFBubbleItUpViewConfiguration.inset.bottom
        
        return defaultHeight + padding
    }
    
    private func invalidateIntrinsicContentSize(completionBlock: (() -> ())?) {
        
        if self.intrinsicContentSize() != self.bounds.size {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.invalidateIntrinsicContentSize()
                //            self.superview?.setNeedsLayout()
                self.superview?.layoutIfNeeded()
                
                }) { (finished) -> Void in
                    completionBlock?()
            }
        } else {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    // MARK:- Handling gestures
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        if gestureRecognizer != self.tapRecognizer {
            return false
        }
        
        if let view = touch.view where view.isKindOfClass(TFBubbleItUpViewCell) {
            return false
        } else {
            return true
        }
    }
    
    func didTapOnView(sender: AnyObject) {
        
        if let last = self.items.last where last.text == "" || !isTextValid(last.text) || self.items.count == self.needPreciseNumberOfItems() {
            self.cellForItemAtIndexPath(NSIndexPath(forItem: self.items.count - 1, inSection: 0))?.becomeFirstResponder()
        } else {
            
            if self.items.count == 0 {
                self.placeholderLabel.hidden = true
            }
            
            self.items.append(TFBubbleItem(text: "", becomeFirstResponder: true)) // insert new data item at the end
            
            // Update collectionView
            self.performBatchUpdates({ () -> Void in
                self.insertItemsAtIndexPaths([NSIndexPath(forItem: self.items.count - 1, inSection:0)])
                }) { (finished) -> Void in
                    // Invalidate intrinsic size when done
                    self.invalidateIntrinsicContentSize(nil)
            }
        }
    }
    
    func isTextValid(text: String) -> Bool {
        if let validation = TFBubbleItUpViewConfiguration.itemValidation {
            return validation(text)
        } else {
            return true
        }
    }
    
    // MARK:- UICollectionViewDelegate and datasource
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: TFBubbleItUpViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(TFBubbleItUpViewCell.identifier, forIndexPath: indexPath) as! TFBubbleItUpViewCell

        cell.delegate = self;
        
        let item = self.items[indexPath.item]
        cell.configureWithItem(item)
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        var item = self.items[indexPath.item]
        
        if item.becomeFirstResponder {
            cell.becomeFirstResponder()
            item.becomeFirstResponder = false
        }
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.items.count
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1;
    }
    
    // MARK:- UICollectionViewFlowLayout delegate
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let item = self.items[indexPath.item]
        
        self.sizingCell.textField.text = item.text
        let size = self.sizingCell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        
        return CGSizeMake(size.width, CGFloat(TFBubbleItUpViewConfiguration.cellHeight))
    }
    
    // MARK:- TFContactCollectionCellDelegate
    
    internal func didChangeText(cell: TFBubbleItUpViewCell, text: String) {
        if let indexPath = self.indexPathForCell(cell) {
            self.items[indexPath.item].text = text
        }
    }

    internal func needUpdateLayout(cell: TFBubbleItUpViewCell) {
        self.collectionViewLayout.invalidateLayout()

        // Update cell frame by its intrinsic size
        var frame = cell.frame
        frame.size.width = cell.intrinsicContentSize().width
        cell.frame = frame
        
        self.invalidateIntrinsicContentSize(nil)
    }
    
    internal func createAndSwitchToNewCell(cell: TFBubbleItUpViewCell) {
        
        // If no indexpath found return
        guard let indexPath = self.indexPathForCell(cell) else {
            return
        }
        
        // If user tries to create new cell when he already has one
        if cell.textField.text == "" {
            return
        }
        
        cell.setMode(.View)
        
        if let preciseNumber = self.needPreciseNumberOfItems() where self.items.count == preciseNumber { // If we reach quantity, return
            cell.resignFirstResponder()
            return
        }
        
        // Create indexPath for the last item
        let newIndexPath = NSIndexPath(forItem: self.items.count - 1, inSection: indexPath.section)
        
        // If the next cell is empty, move to it. Otherwise create new.
        if let nextCell = self.cellForItemAtIndexPath(newIndexPath) as? TFBubbleItUpViewCell where nextCell.textField.text == "" {
            
            nextCell.becomeFirstResponder()
            
        } else {
            self.items.append(TFBubbleItem(text: "", becomeFirstResponder: true)) // insert new data item
            
            // Update collectionView
            self.performBatchUpdates({ () -> Void in
                let newLastIndexPath = NSIndexPath(forItem: self.items.count - 1, inSection: indexPath.section)
                self.insertItemsAtIndexPaths([newLastIndexPath])
                }) { (finished) -> Void in
                    // Invalidate intrinsic size when done
                    self.invalidateIntrinsicContentSize(nil)
                    // The new cell should now become the first reponder
                    //self.cellForItemAtIndexPath(newIndexPath)?.becomeFirstResponder()
            }
        }
    }
    
    func editingDidEnd(cell: TFBubbleItUpViewCell, text: String) {
        
        guard let indexPath = indexPathForCell(cell) else {
            
            return
        }
        
        if text == "" {
            
            
            self.items.removeAtIndex(indexPath.item)
            
            // Update collectionView
            self.performBatchUpdates({ () -> Void in
                self.deleteItemsAtIndexPaths([indexPath])
                }) { (finished) -> Void in
                    // Invalidate intrinsic size when done
                    self.invalidateIntrinsicContentSize(nil)
                    
                    if self.items.count == 0 {
                        self.placeholderLabel.hidden = false
                    }
            }
        } else if text != "" {
            self.bubbleItUpDelegate?.bubbleItUpViewDidFinishEditingBubble(self, text: text)
        }
    }
    
    // MARK: - Helpers
    
    func needPreciseNumberOfItems() -> Int? {
        switch TFBubbleItUpViewConfiguration.numberOfItems {
        case .Unlimited:
            return nil
        case let .Quantity(value):
            return value
        }
    }
}
