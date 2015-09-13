//
//  TFContactViewFlowLayout.swift
//  TFContactCollection
//
//  Created by Aleš Kocur on 12/09/15.
//  Copyright © 2015 The Funtasty. All rights reserved.
//

import UIKit

class TFBubbleItUpViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        // Let FlowLayout give us atributes
        guard let array = super.layoutAttributesForElementsInRect(rect) else {
            
            return nil
        }
        
        let newArray = array.map { (element) -> UICollectionViewLayoutAttributes in
            let attributes = element.copy() as! UICollectionViewLayoutAttributes
            
            if (attributes.representedElementKind == nil) {
                let indexPath = attributes.indexPath
                // Give them the right frame
                attributes.frame = (self.layoutAttributesForItemAtIndexPath(indexPath)?.frame)!
            }
            
            return attributes
        }
        
        return newArray
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)!.copy() as! UICollectionViewLayoutAttributes
        var frame = attributes.frame
        
        if (attributes.frame.origin.x <= self.sectionInset.left) {
            
            return attributes
        }
        
        if indexPath.item == 0 {
            frame.origin.x = self.sectionInset.left
        } else {
            let previousIndexPath = NSIndexPath(forItem: indexPath.item - 1, inSection: indexPath.section)
            let previousAttributes = self.layoutAttributesForItemAtIndexPath(previousIndexPath)!
            
            if (attributes.frame.origin.y > previousAttributes.frame.origin.y) {
                frame.origin.x = self.sectionInset.left
            } else {
                frame.origin.x = CGRectGetMaxX(previousAttributes.frame) + self.minimumInteritemSpacing
            }
        }
        
        attributes.frame = frame;
        
        return attributes;
        
    }
    
}
