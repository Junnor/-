//
//  GlobalFunc.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/10.
//  Copyright © 2017年 moelove. All rights reserved.
//

import Foundation
import UIKit

// 加密相关
func stringAauthParameters() -> String {
    let uid_para = "&uid=" + User.shared.uid
    let oauth_token_para = "&oauth_token=" + User.shared.oauth_token
    let oauth_token_secret_para = "&oauth_token_secret=" + User.shared.oauth_token_secret
    
    return uid_para + oauth_token_para + oauth_token_secret_para
}

// 登陆后的一系列需要参数
func stringParameters(actTo act: String) -> String {
    let userinfoSecret = kSecretKey + act
    let token = userinfoSecret.md5
    let app_time = String(NSDate().timeIntervalSince1970*1000).components(separatedBy: ".").first!
    let app_device = UIDevice.current.identifierForVendor?.uuidString ?? "0"
    
    let sort = [app_device, app_time, token!, User.shared.uid]
    let sorted = sort.sorted { $0 < $1 }
    let appsignSecret = sorted.joined(separator: "&")
    let app_sign = appsignSecret.md5
    
    let app_time_para = "&app_time=" + app_time
    let app_device_para = "&app_device=" + app_device
    let token_para = "&token=" + token!
    let app_sign_para = "&app_sign=" + app_sign!
    
    let version = "&version=2.0"
    
    return token_para + stringAauthParameters() + app_time_para + app_device_para + app_sign_para + version
}

