//
//  KeyboardManager.swift
//  Keyboard
//
//  Created by ryuickhwan on 2019/10/22.
//  Copyright © 2019 ryuickhwan. All rights reserved.
//

import UIKit

enum BehindType {
   case overlap
   case unOverlap
   case obscured
   case unknown
}

final public class KeyboardManager: NSObject {
    
    private weak var _textFieldView: UIView?
    
    private weak var _lastScrollView: UIScrollView?
    
    private var _privateHasPendingAdjustRequest: Bool = false
    
    private var _privateIsKeyboardShowing: Bool = false
    
    private var _startingContentInsets: UIEdgeInsets = UIEdgeInsets()
    
    private var _animationDuration: TimeInterval = 0.25
    
    private var _animationCurve: UIView.AnimationOptions = .curveEaseOut
    
    private var _kbFrame: CGRect = CGRect.zero
    
    private let center: NotificationCenter = NotificationCenter.default
    
    private static var sharedInstence: KeyboardManager = KeyboardManager()
    
    @discardableResult
    static public func shared() -> KeyboardManager {
        return KeyboardManager.sharedInstence
    }
    
    override init() {
        super.init()
        registerNotification()
    }
    
    deinit {
        unRegisterNotification()
    }
    
    private lazy var resignFirstResponderGesture: UITapGestureRecognizer = {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized(_:)))
        tapGesture.cancelsTouchesInView = false

        return tapGesture
    }()
    
    private func registerNotification() {
        
        center.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .keyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardDidShow(_:)),  name: .keyboardDidShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .keyboardWillHide, object: nil)
        
        
        center.addObserver(self, selector: #selector(textFieldViewDidBeginEditing(_:)), name: .textFieldDidBeginEditing, object: nil)
        center.addObserver(self, selector: #selector(textFieldViewDidBeginEditing(_:)), name: .textViewDidBeginEditing, object: nil)
        center.addObserver(self, selector: #selector(textFieldViewDidEndEditing(_:)), name: .textFieldDidEndEditing, object: nil)
        center.addObserver(self, selector: #selector(textFieldViewDidEndEditing(_:)), name: .textViewDidEndEditing, object: nil)
    }
    
    private func unRegisterNotification() {
        
        center.removeObserver(self, name: .keyboardWillShow, object: nil)
        center.removeObserver(self, name: .keyboardDidShow, object: nil)
        center.removeObserver(self, name: .keyboardWillHide, object: nil)
        
        center.removeObserver(self, name: .textFieldDidBeginEditing, object: nil)
        center.removeObserver(self, name: .textViewDidBeginEditing, object: nil)
        center.removeObserver(self, name: .textFieldDidEndEditing, object: nil)
        center.removeObserver(self, name: .textViewDidEndEditing, object: nil)
    }
    
    @objc private func tapRecognized(_ gesture: UITapGestureRecognizer) {
        
        if gesture.state == .ended {
            resignFirstResponder()
        }
    }
    
    public func resignFirstResponder() {
        if let textFieldRetain = _textFieldView {
            
            let isResignFirstResponder = textFieldRetain.resignFirstResponder()
            
            if isResignFirstResponder == false {
                textFieldRetain.becomeFirstResponder()
            }
        }
    }
    
    private func optimizedAdjustPosition() {
        if _privateHasPendingAdjustRequest == false {
            
            _privateHasPendingAdjustRequest = true
            OperationQueue.main.addOperation {
                self.adjustPostion()
                self._privateHasPendingAdjustRequest = false
            }
        }
    }
    
    private func adjustPostion() {
        if _privateHasPendingAdjustRequest == false { return }
        
        var superScrollView: UIScrollView?
        var superView = _textFieldView?.superviewOfClassType(UIScrollView.self) as? UIScrollView
        
        while let view = superView {
            
            if view.isScrollEnabled {
                superScrollView = view
                 break
            } else {
                superView = view.superviewOfClassType(UIScrollView.self) as? UIScrollView
            }
        }
        
        if let lastScrollView = _lastScrollView {
            
            UIView.animate(withDuration: _animationDuration,
                           delay: 0,
                           options: _animationCurve.union(.beginFromCurrentState),
                           animations: { () -> Void in
                                if lastScrollView.contentInset != self._startingContentInsets {
                                    lastScrollView.contentInset = self._startingContentInsets
                            }
            })
        } else if let unwrappedSuperScrollView = superScrollView {
            
            _lastScrollView = unwrappedSuperScrollView
            
            let isBehindScroll = isBehindScrollView()
            
            if isBehindScroll != .unknown, isBehindScroll != .unOverlap {
                _lastScrollView?.contentInset.bottom += _kbFrame.size.height + 10
                _startingContentInsets = unwrappedSuperScrollView.contentInset
            }
        }
        
        let isBehindScroll = isBehindScrollView()
        
        if let textView = self._textFieldView as? UITextView, let lastScrollView = _lastScrollView {
          
            guard let cursorPotition = textView.selectedTextRange?.start, isBehind(view: textView) else { return }
            
            let contentViewSize = lastScrollView.contentSize.height
            let caretPositionRect = textView.caretRect(for: cursorPotition)
            let caretPositionY = caretPositionRect.origin.y - textView.contentOffset.y + caretPositionRect.height
                
            let point = CGPoint(x: 0, y: caretPositionY + textView.frame.origin.y)
            
            if let textViewSuperView = textView.superview {
                let margin = CGFloat(10)
                
                let convertToRect = textViewSuperView.convert(point, to: lastScrollView)
                let maxOffset = max(0, lastScrollView.contentSize.height - lastScrollView.frame.size.height)
                let y = max(0, maxOffset - (contentViewSize - convertToRect.y) + _kbFrame.size.height)
                
                if y != 0, isBehindScroll == .overlap {
                    lastScrollView.setContentOffset(CGPoint(x: 0, y: max(0, y + margin)), animated: true)
                }
            }
        }
    }
    
    func isBehindScrollView() -> BehindType {
        guard let keyWindow = UIApplication.shared.keyWindow, let lastScrollView = _lastScrollView else { return .unknown }
        
        let scrollViewEndPoint = lastScrollView.frame.origin.y + lastScrollView.frame.size.height
        let keyboardOffset = keyWindow.frame.size.height - _kbFrame.size.height
        
        if lastScrollView.frame.origin.y > keyboardOffset {
            return .obscured
        } else if (scrollViewEndPoint < keyboardOffset) == true {
            return .unOverlap
        } else {
            return .overlap
        }
    }
    
    func isBehind(view: UIView?) -> Bool {
        guard let keyWindow = UIApplication.shared.keyWindow, let frontView = view, let superView = frontView.superview else { return false }
        
        let keyWindowToRect = superView.convert(frontView.frame, to: keyWindow).origin.y
        let keyboardMaxY = UIScreen.main.bounds.size.height - _kbFrame.height
        
        print("isBehind: ", keyboardMaxY < keyWindowToRect)
        
        return keyboardMaxY < keyWindowToRect
    }
    
    
    // Keyboard && TextFieldEditing Notification
    @objc private func keyboardWillShow(_ notification: Notification?) {
       
        _privateIsKeyboardShowing = true
        
        if let info = notification?.userInfo {
            let curveUserInfoKey    = UIResponder.keyboardAnimationCurveUserInfoKey
            let durationUserInfoKey = UIResponder.keyboardAnimationDurationUserInfoKey
            let frameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey

            if let curve = info[curveUserInfoKey] as? UInt {
                _animationCurve = .init(rawValue: curve)
            } else {
                _animationCurve = .curveEaseOut
            }

            if let kbFrame = info[frameEndUserInfoKey] as? CGRect {
                _kbFrame = kbFrame
            }

            if let duration = info[durationUserInfoKey] as? TimeInterval {
                if duration != 0.0 {
                    _animationDuration = duration
                }
            } else {
                _animationDuration = 0.25
            }
        }

        optimizedAdjustPosition()
    }
    
    @objc private func keyboardDidShow(_ notification: Notification?) {
       
        if _textFieldView != nil {
            optimizedAdjustPosition()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification?) {
        
        if let unwrappedSuperScrollView = _lastScrollView {
            unwrappedSuperScrollView.contentInset = .zero
            _startingContentInsets = UIEdgeInsets()
            _privateIsKeyboardShowing = false
            _lastScrollView = nil
            _kbFrame = CGRect.zero
        }
    }
    
    @objc private func textFieldViewDidBeginEditing(_ notification: Notification?) {
       
        _textFieldView = notification?.object as? UIView
        _textFieldView?.window?.addGestureRecognizer(resignFirstResponderGesture)
    }
    
    @objc private func textFieldViewDidEndEditing(_ notification: Notification?) {
        
        _textFieldView?.window?.removeGestureRecognizer(resignFirstResponderGesture)
        _textFieldView = nil
    }
}
