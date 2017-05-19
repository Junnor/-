//
//  ClassHelper.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/19.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class ClassHelper: NSObject {

}

extension UIViewController {
    func customizeBackItem() {
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
}

extension String  {
    var md5: String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate(capacity: digestLen)
        
        return String(format: hash as String)
    }
}
