//
//  ViewController.swift
//  Keyboard
//
//  Created by ryuickhwan on 2019/10/22.
//  Copyright © 2019 ryuickhwan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var textView : UITextView!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        
        scrollView.rx.didScroll.subscribe { _ in
            print("postion: \(self.scrollView.contentOffset.y)")
        }.disposed(by: disposeBag)
    }
}

