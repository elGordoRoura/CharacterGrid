//
//  UISegmentedControl+Universe.swift
//  Character Grid
//
//  Created by Christopher J. Roura on 11/5/20.
//

import UIKit

extension UISegmentedControl {
    var selectedUniverse: Universe {
        switch self.selectedSegmentIndex {
        case 0:
            return .ff7r
            
        case 1:
            return .marvel
            
        case 2:
            return .dc
            
        default:
            return .starwars
        }
    }
}
