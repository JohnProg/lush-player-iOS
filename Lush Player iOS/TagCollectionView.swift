//
//  TagCollectionView.swift
//  Lush Player
//
//  Created by Joel Trew on 22/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

// Tag collection view for dynamic height collection views
class TagCollectionView: UICollectionView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (!self.bounds.size.equalTo(self.intrinsicContentSize))
        {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return self.contentSize
    }
}
