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
    
    func login(parameters: Dictionary<String, String>,
                     completionHandler: @escaping (Int, String) -> ()) {
        let loginSecret = kSecretKey + ActType.login
        let token = loginSecret.md5
        let loginUrlString = kHeaderUrl + RequestURL.kLoginUrlString + "&token=" + token!
        
        let url = URL(string: loginUrlString)
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default, headers: nil).responseJSON {                            response in
                            switch response.result {
                            case .success(let json):
                                if let dic = json as? Dictionary<String, AnyObject> {
                                    if let status = dic["status"] as? Int {
                                        let info = dic["info"] as! String
                                        
                                        // user data
                                        if status == 1 {
                                            let data = dic["data"] as? Dictionary<String, String>
                                            if let data = data {
                                                let uid = data["uid"]
                                                let oauth_token = data["oauth_token"]
                                                let oauth_token_secret = data["oauth_token_secret"]
                                                
                                                User.shared.uid = uid ?? ""
                                                User.shared.oauth_token = oauth_token ?? ""
                                                User.shared.oauth_token_secret = oauth_token_secret ?? ""
                                            }
                                        }
                                        
                                        print("login info: \(info)")
                                        completionHandler(status, info)
                                    }
                                }
                            case .failure(let error):
                                print("login error = \(error)")
                            }
                            
        }

    }
        
}
