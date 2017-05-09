//
//  LoginModel.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/9.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire

class LoginModel: NSObject {
    
    class func login(parameters: Dictionary<String, String>,
                     completionHandler: @escaping ((Int)?) -> ()) {
        let loginSecret = kSecretKey + "login"
        let token = loginSecret.md5
        let loginUrlString = kCommonUrl + kLoginRequestUrl + "&token=" + token!
        
        let url = URL(string: loginUrlString)
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default, headers: nil).responseJSON {
                            response in
                            switch response.result {
                            case .success(let json):
                                print("json = \(json)")
                                if let dic = json as? Dictionary<String, AnyObject> {
                                    if let status = dic["status"] as? Int {
                                        if status == 0 {
                                            let info = dic["info"] as! String
                                            print("login info = \(info)")
                                        }
                                        completionHandler(status)
                                    }
                                }
                            case .failure(let error):
                                print("error = \(error)")
                            }
                            
        }

    }

}
