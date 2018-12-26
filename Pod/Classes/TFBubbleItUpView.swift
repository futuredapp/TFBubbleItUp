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

enum DataSourceOperationError: Error {
    case OutOfBounds
}

@objc public protocol TFBubbleItUpViewDelegate {
    func bubbleItUpViewDidFinishEditingBubble(view: TFBubbleItUpView, text: String)
    
    @objc optional func bubbleItUpViewDidChange(view: TFBubbleItUpView, text: String)
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
        self.sizingCell = TFBubbleItUpViewCell(frame: CGRect(x: 0,
                                                             y: 0,
                                                             width: 100,
                                                             height: CGFloat(TFBubbleItUpViewConfiguration.cellHeight)))
        
        self.backgroundColor = .white
        var frame = self.bounds
        frame.size.height = self.minimumHeight()
        self.placeholderLabel = UILabel(frame: frame.insetBy(dx: 20, dy: 0))
        let view = UIView(frame: frame)
        view.addSubview(self.placeholderLabel)
        self.backgroundView = view
        self.placeholderLabel.font = TFBubbleItUpViewConfiguration.placeholderFont
        self.placeholderLabel.textColor = TFBubbleItUpViewConfiguration.placeholderFontColor
        
        self.register(TFBubbleItUpViewCell.self, forCellWithReuseIdentifier: TFBubbleItUpViewCell.identifier)
        
        self.dataSource = self
        self.delegate = self
        
        if let layout = self.collectionViewLayout as? TFBubbleItUpViewFlowLayout {
            layout.sectionInset = TFBubbleItUpViewConfiguration.inset
            layout.minimumInteritemSpacing = TFBubbleItUpViewConfiguration.interitemSpacing
            layout.minimumLineSpacing = TFBubbleItUpViewConfiguration.lineSpacing
        }
        
        self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TFBubbleItUpView.didTapOnView))
        self.addGestureRecognizer(self.tapRecognizer)
    }
    
    public override func prepareForInterfaceBuilder() {
        self.setItems([TFBubbleItem(text: "exm@ex.com"), TFBubbleItem(text: "hello@thefuntasty.com")])
    }
    
    // MARK:- Public API
    
    /// Sets new items and reloads sizes
    func setItems(_ items: [TFBubbleItem]) {
        
        self.items = items
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.collectionViewLayout.invalidateLayout() // Invalidate layout
            self.invalidateIntrinsicContentSize(completionBlock: nil) // Invalidate intrinsic size
        }
        
        self.reloadData() // Reload collectionView
        
        CATransaction.commit()
    }
    
    public func setStringItems(items: [String]) {
        // Set new items
        let bubbleItems = items.map({ (text) -> TFBubbleItem in
            return TFBubbleItem(text: text)
        })
        
        self.setItems(bubbleItems)
    }
    
    /// Returns all non-empty items
    public func stringItems() -> [String] {
        
        return self.items.filter({ (item) -> Bool in item.text != "" }).map({ (item) -> String in item.text })
    }
    
    /// Returns all valid strings
    public func validStrings() -> [String] {
        
        return self.items.filter({ (item) -> Bool in item.text != "" && TFBubbleItUpValidation.isValid(text: item.text) }).map({ (item) -> String in item.text })
    }
    
    public func setPlaceholderText(text: String) {
        self.placeholderLabel.text = text
    }
    
    public func replaceItemsTextAtPosition(position: Int, withText text: String, resign: Bool = true, completion: (() -> ())? = nil) throws {
        if position < 0 || position >= self.items.count {
            throw DataSourceOperationError.OutOfBounds
        }
        
        self.items[position].text = text
        
        if let cell = self.cellForItem(at: IndexPath(item: position, section: 0)) as? TFBubbleItUpViewCell {
            cell.configure(with: self.items[position])
            
            self.needUpdateLayout(cell: cell) {
                self.invalidateIntrinsicContentSize() {
                    
                    if resign {
                        _ = cell.resignFirstResponder()
                    }
                    
                    completion?()
                }
                
            }
        } else {
            completion?()
        }
    }
    
    public func replaceLastInvalidOrInsertItemText(text: String, switchToNext: Bool = true, completion: (() -> ())? = nil) {
        
        if let validator = TFBubbleItUpViewConfiguration.itemValidation,
           let item = self.items.last,
           !validator(item.text) {
            
            let position = self.items.index(where: { (i) -> Bool in i.text == item.text })
            
            // Force try because we know that this position exists
            try! self.replaceItemsTextAtPosition(position: position!, withText: text) {
                
                if switchToNext {
                    self.selectLastPossible()
                }
                completion?()
            }
            
            
        } else {
            _ = addStringItem(text: text) {
                
                if switchToNext {
                    self.selectLastPossible()
                }
                completion?()
            }
        }
    }
    
    /// Adds item if possible, returning Bool indicates success or failure
    public func addStringItem(text: String, completion: (()->())? = nil) -> Bool {
        
        if self.items.count == self.needPreciseNumberOfItems() && self.items.last?.text != "" {
            
            return false
        }
        
        if self.items.last != nil && self.items.last!.text == ""  {
            self.items[self.items.count - 1].text = text
            
            if let cell = self.cellForItem(at: IndexPath(item: self.items.count - 1, section: 0)) as? TFBubbleItUpViewCell {
                cell.configure(with: self.items[self.items.count - 1])
                _ = cell.resignFirstResponder()
                self.needUpdateLayout(cell: cell, completion: completion)
            }
            
        } else {
            self.items.append(TFBubbleItem(text: text))
            
            self.performBatchUpdates({ () -> Void in
                let newLastIndexPath = IndexPath(item: self.items.count - 1, section: 0)
                self.insertItems(at: [newLastIndexPath])
                }) { (finished) -> Void in
                    // Invalidate intrinsic size when done
                    self.invalidateIntrinsicContentSize(completionBlock: completion)
            }
        }
        
        return true
    }
    
    public func removeStringItem(text: String) -> Bool {
        let index = self.items.index { (item) -> Bool in item.text == text }
        
        guard let i = index else {
            
            return false
        }
        
        self.items.remove(at: i)
        
        self.performBatchUpdates({ () -> Void in
            let newLastIndexPath = IndexPath(item: i, section: 0)
            self.deleteItems(at: [newLastIndexPath])
            
            }) { (finished) -> Void in
                // Invalidate intrinsic size when done
                self.invalidateIntrinsicContentSize(completionBlock: nil)
        }
        
        return true
    }
    
    public override func becomeFirstResponder() -> Bool {
        
        self.selectLastPossible()
        
        return true
    }
    
    // MARK:- Autolayout
    
    override public var intrinsicContentSize: CGSize {
        // Calculate custom intrinsic size by collectionViewLayouts contentent size
        let size = (self.collectionViewLayout as! UICollectionViewFlowLayout).collectionViewContentSize
        
        return CGSize(width: self.bounds.width, height: max(self.minimumHeight(), size.height))
    }
    
    func minimumHeight() -> CGFloat {
        let defaultHeight: CGFloat = CGFloat(TFBubbleItUpViewConfiguration.cellHeight)
        let padding = TFBubbleItUpViewConfiguration.inset.top + TFBubbleItUpViewConfiguration.inset.bottom
        
        return defaultHeight + padding
    }
    
    private func invalidateIntrinsicContentSize(completionBlock: (() -> ())?) {
        
        if self.intrinsicContentSize != self.bounds.size {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.invalidateIntrinsicContentSize()
                
                }) { (finished) -> Void in
                    completionBlock?()
            }
        } else {
            //self.invalidateIntrinsicContentSize()
            completionBlock?()
        }
    }
    
    // MARK:- Handling gestures
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if gestureRecognizer != self.tapRecognizer {
            return false
        }
        
        if let view = touch.view, view.isKind(of: TFBubbleItUpViewCell.self) {
            return false
        } else {
            return true
        }
    }
    
    func didTapOnView(sender: AnyObject) {
        self.selectLastPossible()
    }
    
    internal func selectLastPossible() {
        if let last = self.items.last, last.text == "" || !isTextValid(text: last.text) || self.items.count == self.needPreciseNumberOfItems() {
            self.cellForItem(at: IndexPath(item: self.items.count - 1, section: 0))?.becomeFirstResponder()
        } else {
            
            if self.items.count == 0 {
                self.placeholderLabel.isHidden = true
            }
            
            self.items.append(TFBubbleItem(text: "", becomeFirstResponder: true)) // insert new data item at the end
            
            // Update collectionView
            self.performBatchUpdates({ () -> Void in
                self.insertItems(at: [IndexPath(item: self.items.count - 1, section:0)])
                }) { (finished) -> Void in
                    // Invalidate intrinsic size when done
                    self.invalidateIntrinsicContentSize(completionBlock: nil)
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
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TFBubbleItUpViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TFBubbleItUpViewCell.identifier, for: indexPath as IndexPath) as! TFBubbleItUpViewCell
        
        cell.delegate = self;
        
        let item = self.items[indexPath.item]
        cell.configure(with: item)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var item = self.items[indexPath.item]
        
        if item.becomeFirstResponder {
            cell.becomeFirstResponder()
            item.becomeFirstResponder = false
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.items.count
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1;
    }
    
    // MARK:- UICollectionViewFlowLayout delegate
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let item = self.items[indexPath.item]
        
        self.sizingCell.textField.text = item.text
        let size = self.sizingCell.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        
        let layoutInset = (self.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset
        let maximumWidth = self.bounds.width - layoutInset.left - layoutInset.right
        
        return CGSize(width: min(size.width, maximumWidth), height: CGFloat(TFBubbleItUpViewConfiguration.cellHeight))
    }
    
    // MARK:- TFContactCollectionCellDelegate
    
    internal func didChangeText(cell: TFBubbleItUpViewCell, text: String) {
        if let indexPath = self.indexPath(for: cell) {
            self.items[indexPath.item].text = text
        }
        
        self.bubbleItUpDelegate?.bubbleItUpViewDidChange?(view: self, text:text)
    }
    
    internal func needUpdateLayout(cell: TFBubbleItUpViewCell) {
        self.needUpdateLayout(cell: cell, completion:nil)
    }
    
    func needUpdateLayout(cell: TFBubbleItUpViewCell, completion: (() -> ())?) {
        self.collectionViewLayout.invalidateLayout()
        
        // Update cell frame by its intrinsic size
        var frame = cell.frame
        frame.size.width = cell.intrinsicContentSize.width
        cell.frame = frame
        
        self.invalidateIntrinsicContentSize(completionBlock: completion)
    }
    
    internal func createAndSwitchToNewCell(cell: TFBubbleItUpViewCell) {
        
        // If no indexpath found return
        guard let indexPath = self.indexPath(for: cell) else {
            return
        }
        
        // If user tries to create new cell when he already has one
        if cell.textField.text == "" {
            return
        }
        
        cell.setMode(.View)
        
        if let preciseNumber = self.needPreciseNumberOfItems(), self.items.count == preciseNumber { // If we reach quantity, return
            _ = cell.resignFirstResponder()
            return
        }
        
        // Create indexPath for the last item
        let newIndexPath = IndexPath(item: self.items.count - 1, section: indexPath.section)
        
        // If the next cell is empty, move to it. Otherwise create new.
        if let nextCell = self.cellForItem(at: newIndexPath) as? TFBubbleItUpViewCell, nextCell.textField.text == "" {
            
            _ = nextCell.becomeFirstResponder()
            
        } else {
            self.items.append(TFBubbleItem(text: "", becomeFirstResponder: true)) // insert new data item
            
            // Update collectionView
            self.performBatchUpdates({ () -> Void in
                let newLastIndexPath = IndexPath(item: self.items.count - 1, section: indexPath.section)
                self.insertItems(at: [newLastIndexPath])
                }) { (finished) -> Void in
                    // Invalidate intrinsic size when done
                    self.invalidateIntrinsicContentSize(completionBlock: nil)
                    // The new cell should now become the first reponder
                    //self.cellForItemAtIndexPath(newIndexPath)?.becomeFirstResponder()
            }
        }
    }
    
    func editingDidEnd(cell: TFBubbleItUpViewCell, text: String) {
        
        guard let indexPath = indexPath(for: cell) else {
            
            return
        }
        
        if text == "" {
            
            self.items.remove(at: indexPath.item)
            
            // Update collectionView
            self.performBatchUpdates({ () -> Void in
                self.deleteItems(at: [indexPath])
                }) { (finished) -> Void in
                    // Invalidate intrinsic size when done
                    self.invalidateIntrinsicContentSize(completionBlock: nil)
                    
                    if self.items.count == 0 {
                        self.placeholderLabel.isHidden = false
                    }
            }
        } else {
            self.bubbleItUpDelegate?.bubbleItUpViewDidFinishEditingBubble(view: self, text: text)
        }
    }
    
    func shouldDeleteCellInFrontOfCell(cell: TFBubbleItUpViewCell) {
        
        guard let cellsIndexPath = self.indexPath(for: cell) else {
            assertionFailure("There should be a index for that cell!")
            return
        }
        
        let itemIndex = cellsIndexPath.item
        
        // Don't do anything if there is only one item
        if itemIndex == 0 {
            return
        }
        
        let previousItemIndex = itemIndex - 1
        
        // Remove item
        
        do {
            try self.removeItem(at: previousItemIndex) {
                self.bubbleItUpDelegate?.bubbleItUpViewDidChange?(view: self, text:"")
            }
        } catch DataSourceOperationError.OutOfBounds {
            print("Error occured while removing item")
        } catch {
            
        }
    }
    
    // MARK: - Helpers
    
    func removeItem(at index: Int, completion: (() -> ())?) throws {
        
        if self.items.count <= index || index < 0 {
            throw DataSourceOperationError.OutOfBounds
        }
        
        self.items.remove(at: index)
        
        // Update collectionView
        self.performBatchUpdates({ () -> Void in
            self.deleteItems(at: [IndexPath(item: index, section: 0)])
            
            }) {[weak self] (finished) -> Void in
                // Invalidate intrinsic size when done
                self?.invalidateIntrinsicContentSize(completionBlock: nil)
                completion?()
        }
    }
    
    func needPreciseNumberOfItems() -> Int? {
        switch TFBubbleItUpViewConfiguration.numberOfItems {
        case .Unlimited:
            return nil
        case let .Quantity(value):
            return value
        }
    }
}
