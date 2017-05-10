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
    
    
    func requestUserInfo(completionHandler: @escaping (Int, String?) -> ()) {
        let stringPara = stringParameters(actTo: ActType.getuinfo)
        let userinfoString = kHeaderUrl + RequestURL.kUserInfoUrlString + stringPara
        let url = URL(string: userinfoString)

        let parameters = ["uid": NSString(string: User.shared.uid).integerValue]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in

                            switch response.result {
                            case .success(let json):
                                if let dic = json as? Dictionary<String, AnyObject> {
                                    guard let status = dic["status"] as? Int, status == 1 else {
                                        let info = dic["info"] as? String
                                        completionHandler(0, info)
                                        return
                                    }
                                    if let data = dic["data"] as? Dictionary<String, AnyObject> {
                                        let user = User.shared
                                        
                                        let uname = data["uname"] as? String
                                        let isBusiness = data["is_business"] as? String
                                        let avatarUrlString = data["avatar"] as? String
                                        let gender = data["sex"] as? String
                                        
                                        let mcoins = data["mcoins"]
                                        if mcoins is Float {
                                            user.mcoins = mcoins as! Float
                                        } else if mcoins is String {
                                            user.mcoins = Float((mcoins as! String))!
                                        }
                                        
                                        user.avatarString = avatarUrlString ?? ""
                                        user.uname = uname ?? ""
                                        user.gender = gender ?? ""
                                        
                                        if isBusiness != nil {
                                            switch isBusiness! {
                                            case "0": user.isBusiness = "不是商户"
                                            case "1": user.isBusiness = "普通商户"
                                            case "2": user.isBusiness = "高级商户"
                                            case "2": user.isBusiness = "超级商户"
                                            default: break
                                            }
                                        }

                                        completionHandler(status, nil)
                                    }
                                }
                            case .failure(let error):
                                print("get user info error: \(error)")
                            }
        }
    }
    
}
