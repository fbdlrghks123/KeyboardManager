//
//  KeyboardManager.swift
//  Keyboard
//
//  Created by ryuickhwan on 2019/10/22.
//  Copyright © 2019 ryuickhwan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class KeyboardManager: NSObject, UIGestureRecognizerDelegate {
    
    private var _kbShowNotification: Notification?
    
    private let center = NotificationCenter.default
    private static var sharedInstence = KeyboardManager()
    
    private var _privateHasPendingAdjustRequest = false
    
    weak var _textFieldView: UIView?
    weak var _lastScrollView: UIScrollView?
    
    var _privateIsKeyboardShowing = false
    
    var _startingContentInsets = UIEdgeInsets()
    
    var _animationDuration: TimeInterval = 0.25
    
    var _animationCurve: UIView.AnimationOptions = .curveEaseOut
    
    var _beforeY : CGFloat? = CGFloat(0)
    
    var _kbFrame = CGRect.zero
    
    @discardableResult
    static func shared() -> KeyboardManager {
        return KeyboardManager.sharedInstence
    }
    
    private var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        registerAllNotification()
    }
    
    deinit {
        unRegisterAllNotification()
    }
    
    lazy var resignFirstResponderGesture: UITapGestureRecognizer = {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self

        return tapGesture
    }()
    
    
    private func registerAllNotification() {
        let textFieldDidBeginEditing = center.rx.notification(.textFieldDidBeginEditing)
        let textFieldDidEndEditing   = center.rx.notification(.textFieldDidEndEditing)
        
        let textViewDidBeginEditing = center.rx.notification(.textViewDidBeginEditing)
        let textViewDidEndEditing   = center.rx.notification(.textViewDidEndEditing)
        
        Observable.merge([textFieldDidBeginEditing, textViewDidBeginEditing])
            .bind(to: self.rx.addGesture)
            .disposed(by: disposeBag)
               
        Observable.merge([textFieldDidEndEditing, textViewDidEndEditing])
           .bind(to: self.rx.removeGesture)
           .disposed(by: disposeBag)
        
        registerKeyboardNotification()
    }
    
    private func unRegisterAllNotification() {
        disposeBag = DisposeBag()
    }
    
    private func registerKeyboardNotification() {
        
        center.rx.notification(.keyboardWillShow)
            .bind(to: self.rx.willShow)
            .disposed(by: disposeBag)
        
        center.rx.notification(.keyboardDidShow)
            .bind(to: self.rx.didShow)
            .disposed(by: disposeBag)

        center.rx.notification(.keyboardWillHide)
            .bind(to: self.rx.willHide)
            .disposed(by: disposeBag)
    }
    
    @objc private func tapRecognized(_ gesture: UITapGestureRecognizer) {
        
        if gesture.state == .ended {
            resignFirstResponder()
        }
    }
    
    private func resignFirstResponder() {
        if let textFieldRetain = _textFieldView {
            
            let isResignFirstResponder = textFieldRetain.resignFirstResponder()
            
            if isResignFirstResponder == false {
                textFieldRetain.becomeFirstResponder()
            }
        }
    }
    
    func optimizedAdjustPosition() {
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
            _lastScrollView?.contentInset.bottom += _kbFrame.size.height
            _startingContentInsets = unwrappedSuperScrollView.contentInset
        }
        //            let point = CGPoint(x: textView.frame.origin.x, y: textView.frame.maxY)
        
        if let textView = self._textFieldView as? UITextView, let lastScrollView = _lastScrollView {
          
            guard let cursorPotition = textView.selectedTextRange?.start else { return }
            let caretPositionRect = textView.caretRect(for: cursorPotition)
            let caretPositionY = caretPositionRect.origin.y - textView.contentOffset.y + caretPositionRect.height
                
            let contentViewSize = lastScrollView.contentSize.height

            let point = CGPoint(x: 0, y: caretPositionY + textView.frame.origin.y)
            
            if let textViewSuperView = textView.superview {
                let margin = CGFloat(10)
                
                let convertToRect = textViewSuperView.convert(point, to: lastScrollView)
                
                let maxOffset = max(0, lastScrollView.contentSize.height - UIScreen.main.bounds.height)
                let y = max(0, maxOffset - (contentViewSize - convertToRect.y) + _kbFrame.size.height)
                
                if y != 0 {
                    _beforeY = y + margin
                    lastScrollView.setContentOffset(CGPoint(x: 0, y: y + margin), animated: true)
                }
            }
        }
    }
}

extension Reactive where Base: KeyboardManager {
    var addGesture: Binder<Notification> {
        return Binder(base) { base, notification in
            base._textFieldView = notification.object as? UIView
            base._textFieldView?.window?.addGestureRecognizer(base.resignFirstResponderGesture)
        }
    }
    
    var removeGesture: Binder<Notification> {
        return Binder(base) { base, notification in
            base._textFieldView?.window?.removeGestureRecognizer(base.resignFirstResponderGesture)
            base._textFieldView = nil
        }
    }
    
    var willShow: Binder<Notification> {
        return Binder(base) { base, notification in
            
            base._privateIsKeyboardShowing = true
            
//            let oldKBFrame = base._kbFrame
            
            if let info = notification.userInfo {
                let curveUserInfoKey    = UIResponder.keyboardAnimationCurveUserInfoKey
                let durationUserInfoKey = UIResponder.keyboardAnimationDurationUserInfoKey
                let frameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey
                
                if let curve = info[curveUserInfoKey] as? UInt {
                    base._animationCurve = .init(rawValue: curve)
                } else {
                    base._animationCurve = .curveEaseOut
                }
                
                if let kbFrame = info[frameEndUserInfoKey] as? CGRect {
                    base._kbFrame = kbFrame
                }
                
                if let duration = info[durationUserInfoKey] as? TimeInterval {
                    if duration != 0.0 {
                        base._animationDuration = duration
                    }
                } else {
                    base._animationDuration = 0.25
                }
            }
            
//            if /* base._kbFrame.equalTo(oldKBFrame) == false , */let _ = base._textFieldView,
//                base._privateIsKeyboardShowing == true  {
               
                base.optimizedAdjustPosition()
//            }
        }
    }
    
    var didShow: Binder<Notification> {
        return Binder(base) { base, notification in
            if let _ = base._textFieldView {
                base.optimizedAdjustPosition()
            }
        }
    }
    
    var willHide: Binder<Notification> {
        return Binder(base) { base, notification in
            if let unwrappedSuperScrollView = base._lastScrollView {
                if let y = base._beforeY, let lastScroll = base._lastScrollView {
                    OperationQueue.main.addOperation {
                        let maxY = max(0, lastScroll.contentOffset.y - y)
                        lastScroll.setContentOffset(CGPoint(x: 0, y: maxY), animated: true)
                    }
                }
                unwrappedSuperScrollView.contentInset = .zero
                base._startingContentInsets = UIEdgeInsets()
                base._privateIsKeyboardShowing = false
                base._lastScrollView = nil
                base._kbFrame = CGRect.zero
                
                
            }
        }
    }
}
