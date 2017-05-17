//
//  CustomNaviBarView.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/11.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class CustomNaviBarView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // r:31, g:31, b:31
    static func naviBarViewFromNib() -> CustomNaviBarView {
        return  Bundle.main.loadNibNamed("CustomNaviBarView",
                                         owner: nil,
                                         options: nil)![0] as! CustomNaviBarView
    }
}
