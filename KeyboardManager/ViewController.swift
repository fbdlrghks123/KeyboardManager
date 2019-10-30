//
//  ViewController.swift
//  Keyboard
//
//  Created by ryuickhwan on 2019/10/22.
//  Copyright © 2019 ryuickhwan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var textView : UITextView! {
        didSet {
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UIColor.black.cgColor
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("postion: \(scrollView.contentOffset.y)")
    }
}

