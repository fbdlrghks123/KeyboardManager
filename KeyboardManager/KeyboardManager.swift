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

enum BehindType {
    case overlap
    case unOverlap
    case obscured
    case unknown
}

class KeyboardManager: NSObject {
    
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
    
    func resignFirstResponder() {
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
        
        if lastScrollView.frame.origin.y > keyboardOffset { // 키보드에 가려짐
            return .obscured
        } else if (scrollViewEndPoint < keyboardOffset) == true { // 겹치지 않음
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
}

extension Reactive where Base: KeyboardManager {
    var addGesture: Binder<Notification> {
        return Binder(base) { base, notification in
            base._textFieldView = notification.object as? UIView
            base._textFieldView?.window?.addGestureRecognizer(base.resignFirstResponderGesture)
        }
    }
    
    var removeGesture: Binder<Notification> {
        return Binder(base) { base, _ in
            base._textFieldView?.window?.removeGestureRecognizer(base.resignFirstResponderGesture)
            base._textFieldView = nil
        }
    }
    
    var willShow: Binder<Notification> {
        return Binder(base) { base, notification in
            
            base._privateIsKeyboardShowing = true
            
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
            
            base.optimizedAdjustPosition()
        }
    }
    
    var didShow: Binder<Notification> {
        return Binder(base) { base, _ in
            if base._textFieldView != nil {
                base.optimizedAdjustPosition()
            }
        }
    }
    
    var willHide: Binder<Notification> {
        return Binder(base) { base, _ in
            if let unwrappedSuperScrollView = base._lastScrollView {
                unwrappedSuperScrollView.contentInset = .zero
                base._startingContentInsets = UIEdgeInsets()
                base._privateIsKeyboardShowing = false
                base._lastScrollView = nil
                base._kbFrame = CGRect.zero
            }
        }
    }
}
