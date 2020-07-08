//
//  TFContactViewFlowLayout.swift
//  TFContactCollection
//
//  Created by Aleš Kocur on 12/09/15.
//  Copyright © 2015 The Funtasty. All rights reserved.
//

import UIKit

class TFBubbleItUpViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        // Let FlowLayout give us atributes
        guard let array = super.layoutAttributesForElements(in: rect) else {
            
            return nil
        }
        
        let newArray = array.map { (element) -> UICollectionViewLayoutAttributes in
            let attributes = element.copy() as! UICollectionViewLayoutAttributes
            
            if (attributes.representedElementKind == nil) {
                let indexPath = attributes.indexPath
                // Give them the right frame
                attributes.frame = (self.layoutAttributesForItem(at: indexPath)?.frame)!
            }
            
            return attributes
        }
        
        return newArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attributes = super.layoutAttributesForItem(at: indexPath)!.copy() as! UICollectionViewLayoutAttributes
        var frame = attributes.frame
        
        if (attributes.frame.origin.x <= self.sectionInset.left) {
            
            return attributes
        }
        
        if indexPath.item == 0 {
            frame.origin.x = self.sectionInset.left
        } else {
            let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            let previousAttributes = self.layoutAttributesForItem(at: previousIndexPath)!
            
            if (attributes.frame.origin.y > previousAttributes.frame.origin.y) {
                frame.origin.x = self.sectionInset.left
            } else {
                frame.origin.x = previousAttributes.frame.maxX + self.minimumInteritemSpacing
            }
        }
        
        attributes.frame = frame;
        
        return attributes;
        
    }
    
}
