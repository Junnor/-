//
//  FeebackViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/9.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class FeebackViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var publishButton: UIButton!
    
    @IBAction func publish() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "反馈"
    }

}
