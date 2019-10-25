//
//  KeyboardManager+Extension.swift
//  Keyboard
//
//  Created by ryuickhwan on 2019/10/23.
//  Copyright © 2019 ryuickhwan. All rights reserved.
//

import UIKit

extension UIView {
    func superviewOfClassType(_ classType: UIView.Type, belowView: UIView? = nil) -> UIView? {

        var superView = superview
        
        while let unwrappedSuperView = superView {
            
            if unwrappedSuperView.isKind(of: classType) {
                
                if unwrappedSuperView.isKind(of: UIScrollView.self) {
                    
                    let classNameString = NSStringFromClass(type(of: unwrappedSuperView.self))

                    if unwrappedSuperView.superview?.isKind(of: UITableView.self) == false &&
                        unwrappedSuperView.superview?.isKind(of: UITableViewCell.self) == false &&
                        classNameString.hasPrefix("_") == false {
                        return superView
                    }
                } else {
                    return superView
                }
            } else if unwrappedSuperView == belowView {
                return nil
            }
            
            superView = unwrappedSuperView.superview
        }
        
        return nil
    }
}
