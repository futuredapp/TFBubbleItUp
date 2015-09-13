//
//  TFContactCollection.swift
//  TFContactCollection
//
//  Created by Aleš Kocur on 12/09/15.
//  Copyright © 2015 The Funtasty. All rights reserved.
//

import UIKit

struct TFBubbleItem {
    var text: String
    var becomeFirstResponder: Bool = false
    
    init(text: String, becomeFirstResponder: Bool = false) {
        self.text = text
        self.becomeFirstResponder = becomeFirstResponder
    }
}

@IBDesignable public class TFBubbleItUpView: UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate, TFBubbleItUpViewCellDelegate {

    private var items: [TFBubbleItem] = [TFBubbleItem(text: "")]
    private var sizingCell: TFBubbleItUpViewCell!
    private var tapRecognizer: UITapGestureRecognizer!
    
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
        self.setContactItems([TFBubbleItem(text: "exm@ex.com"), TFBubbleItem(text: "hello@thefuntasty.com")])
    }
    
    // MARK:- Public API
    
    /// Sets new items and reloads sizes
    func setContactItems(items: [TFBubbleItem]) {
        self.items = items // Set new items
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.collectionViewLayout.invalidateLayout() // Invalidate layout
            self.invalidateIntrinsicContentSize(nil) // Invalidate intrinsic size
        }
        
        self.reloadData() // Reload collectionView
        
        CATransaction.commit()
    }
    
    // MARK:- Autolayout
    
    override public func intrinsicContentSize() -> CGSize {
        // Calculate custom intrinsic size by collectionViewLayouts contentent size
        let size = (self.collectionViewLayout as! UICollectionViewFlowLayout).collectionViewContentSize()
        
        return CGSizeMake(CGRectGetWidth(self.bounds), size.height)
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
        
        if self.items.last?.text == "" {
            self.cellForItemAtIndexPath(NSIndexPath(forItem: self.items.count - 1, inSection: 0))?.becomeFirstResponder()
        } else {
            self.items.append(TFBubbleItem(text: "", becomeFirstResponder: true)) // insert new data item at the end
            
            // Update collectionView
            self.performBatchUpdates({ () -> Void in
                self.insertItemsAtIndexPaths([NSIndexPath(forItem: self.items.count - 1, inSection:0)])
                }) { (finished) -> Void in
                    // Invalidate intrinsic size when done
                    self.invalidateIntrinsicContentSize(nil)
                    // The new cell should now become the first reponder
                    //self.cellForItemAtIndexPath(newIndexPath)?.becomeFirstResponder()
            }
        }
        
    }
    
    // MARK:- UICollectionViewDelegate and datasource
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: TFBubbleItUpViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(TFBubbleItUpViewCell.identifier, forIndexPath: indexPath) as! TFBubbleItUpViewCell

        cell.delegate = self;
        
        var item = self.items[indexPath.item]
        cell.textField.text = item.text
        cell.setMode(.View)
        
        if item.becomeFirstResponder {
            cell.becomeFirstResponder()
            item.becomeFirstResponder = false
        }
        
        return cell
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
        
        // Create indexPath for item next to current
        let newIndexPath = NSIndexPath(forItem: indexPath.item + 1, inSection: indexPath.section)
        
        // If the next cell is empty, move to it. Otherwise create new.
        if let nextCell = self.cellForItemAtIndexPath(newIndexPath) as? TFBubbleItUpViewCell where nextCell.textField.text == "" {
            
            nextCell.becomeFirstResponder()
            
        } else {
            self.items.insert(TFBubbleItem(text: "", becomeFirstResponder: true), atIndex: newIndexPath.item) // insert new data item
            
            // Update collectionView
            self.performBatchUpdates({ () -> Void in
                self.insertItemsAtIndexPaths([newIndexPath])
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
        
        let isLast = self.items.count - 1 == indexPath.item
        
        if text == "" && !isLast {
            self.items.removeAtIndex(indexPath.item)
            
            // Update collectionView
            self.performBatchUpdates({ () -> Void in
                self.deleteItemsAtIndexPaths([indexPath])
                }) { (finished) -> Void in
                    // Invalidate intrinsic size when done
                    self.invalidateIntrinsicContentSize(nil)
            }
        }
    }
    
}
