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
        let loginSecret = kSecretKey + "login"
        let token = loginSecret.md5
        let loginUrlString = kCommonUrl + kLoginRequestUrl + "&token=" + token!
        
        let url = URL(string: loginUrlString)
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default, headers: nil).responseJSON { [weak self]
                            response in
                            switch response.result {
                            case .success(let json):
                                print("json = \(json)")
                                if let dic = json as? Dictionary<String, AnyObject> {
                                    if let status = dic["status"] as? Int {
                                        let info = dic["info"] as! String
                                        
                                        // user data
                                        if status == 1 {
                                            let data = dic["data"] as? Dictionary<String, String>
                                            if let data = data {
                                                let uid = data["uid"]!
                                                let oauth_token = data["oauth_token"]!
                                                let oauth_token_secret = data["oauth_token_secret"]!
                                                
                                                self?.uid = uid
                                                self?.oauth_token = oauth_token
                                                self?.oauth_token_secret = oauth_token_secret
                                                
                                                self?.requestUserInfo(parameters: ["uid": uid])
                                                // post
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
    
    private func requestUserInfo(parameters: Dictionary<String, String>) {
        let urlParameter = urlParameters()
        let userinfoString = kCommonUrl + kLoginRequestUrl + urlParameter
        let url = URL(string: userinfoString)
        Alamofire.request(url!, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            print("userinfo responce: \(response)")
        }
    }

    private var oauth_token: String!
    private var oauth_token_secret: String!
    private var uid: String!

    private func urlParameters() -> String {
        let userinfoSecret = kSecretKey + "getuinfo"
        let userinfoToken = userinfoSecret.md5
        let appsignSecret = self.oauth_token + self.oauth_token_secret + self.uid + userinfoToken!
        let token = appsignSecret.md5
        
        let app_time = String(NSDate().timeIntervalSince1970)
        let app_device = UIDevice.current.identifierForVendor!.uuidString
        let uid = self.uid!
        
        let appTimePara = "&app_time" + app_time
        let appDeveicePara = "&app_device" + app_device
        let tokenPara = "&token" + token!
        let uidPara = "&uid" + uid
        
        return appTimePara + appDeveicePara + tokenPara + uidPara
    }

}
