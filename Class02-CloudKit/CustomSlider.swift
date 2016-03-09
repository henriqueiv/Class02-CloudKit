//
//  CustomSlider.swift
//  Class02-CloudKit
//
//  Created by Henrique Valcanaia on 3/8/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {

    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        var newBounds = super.trackRectForBounds(bounds)
        newBounds.size.height = 12
        return newBounds
    }
    
}
