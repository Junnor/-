//
//  User.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/10.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire

final class User {
    
    // MARK: - singleton
    static let shared = User()
    private init() {}
    
    // MARK: - Properties
    
    // 用户ID
    var uid = String()
    
    // 用户加密信息
    var oauth_token = String()
    
    // 用户加密信息
    var oauth_token_secret = String()
    
    /*
     1: 男
     2: 女
     */
    
    var gender = String()
    
    // 用户名
    var uname = String()
    
    // 头像 url string
    var avatarString = String()
    
    /*
     0: 不是商户
     1: 普通商户
     2: 高级商户
     3: 超级商户
     */
    var isBusiness = String()
    
    // 金额, 有两位小数点
    var mcoins: Float = 0.00
    

    // MARK: - clean after sign out
    func clean() {
        uid = ""
        oauth_token = ""
        oauth_token_secret = ""
        gender = ""
        uname = ""
        avatarString = ""
        isBusiness = ""
        mcoins = 0.00
        
        cleanStoredOauthData()
    }
}

extension User {
    
    class func requestUserInfo(completionHandler: @escaping (Bool, String?) -> ()) {
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
                                        completionHandler(false, info)
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
                                        
                                        completionHandler(true, nil)
                                    }
                                }
                            case .failure(let error):
                                print("get user info error: \(error)")
                            }
        }
    }
}
