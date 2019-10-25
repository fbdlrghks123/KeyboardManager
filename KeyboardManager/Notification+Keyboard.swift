//
//  Notification+Keyboard.swift
//  Keyboard
//
//  Created by ryuickhwan on 2019/10/23.
//  Copyright © 2019 ryuickhwan. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let keyboardWillShow = UIResponder.keyboardWillShowNotification
    static let keyboardDidShow  = UIResponder.keyboardDidShowNotification
    static let keyboardWillHide = UIResponder.keyboardWillHideNotification
    static let keyboardDidHide  = UIResponder.keyboardDidHideNotification
    
    static let textFieldDidBeginEditing = UITextField.textDidBeginEditingNotification
    static let textFieldDidEndEditing   = UITextField.textDidEndEditingNotification
    static let textViewDidBeginEditing  = UITextView.textDidBeginEditingNotification
    static let textViewDidEndEditing    = UITextView.textDidEndEditingNotification
}
