//
//  UserPay.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/19.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum Pay: String {
    case wechat = "wechat"
    case alipay = "alipay"
}

class UserPay {
    
    var orderPrice: Float!
    var tradeNo: String!
    var order_id: String!
    
    // for alipay
    var alipay_sign_str: String!

    // for wechat
    var wechat_sign_str: String!
    var appid: String!

    
    convenience init(orderPrice: Float) {
        self.init()
        
        self.orderPrice = orderPrice
    }
}

extension UserPay {
    func pay(withType payType: Pay, orderPrice: Float, completionHandler: @escaping (Bool, String?) -> ()) {
        self.orderPrice = orderPrice
        
        let stringPara = stringParameters(actTo: ActType.rechargeMb)
        let userinfoString = kHeaderUrl + RequestURL.kRechargeUrlString + stringPara
        
        let url = URL(string: userinfoString)
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "order_price": orderPrice,
                          "pay_type": payType.rawValue] as [String : Any]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default, headers: nil).responseJSON {
                            response in
                            switch response.result {
                            case .success(let jsonResource):
                                print("pay json: \(jsonResource)")
                                let json = JSON(jsonResource)
                                let info = json["info"].stringValue
                                if json["status"].intValue == 1 {
                                    let order_id = json["order_id"].stringValue
                                    self.order_id = order_id
                                    switch payType {
                                    case .alipay:
                                        let sign_str = json["sign_str"].stringValue
                                        
                                        self.alipay_sign_str = sign_str
                                    case .wechat:
                                        if let wechatSource = json["wx_sign"].dictionary {
                                            let wechat = JSON(wechatSource)
                                            let appid = wechat["appid"].stringValue
                                            let sign = wechat["sign"].stringValue

//                                            let noncestr = wechat["noncestr"].stringValue
//                                            let package = wechat["package"].stringValue
//                                            let packages = wechat["packages"].stringValue
//                                            let partnerid = wechat["partnerid"].stringValue
//                                            let prepayid = wechat["prepayid"].stringValue
//                                            let timestamp = wechat["timestamp"].stringValue
                                            
                                            self.wechat_sign_str = sign
                                            self.appid = appid
                                        }
                                    }
                                    completionHandler(true, nil)
                                }
                                completionHandler(false, info)
                            case .failure(let error):
                                print("pay error: \(error)")
                            }
                            
        }
        
    }
    
    func paySuccess(callback completionHandler: @escaping (Bool, String?) -> ()) {
        let stringPara = stringParameters(actTo: ActType.recharge_back)
        let userinfoString = kHeaderUrl + RequestURL.kRechargeBackUrlString + stringPara
        
        let url = URL(string: userinfoString)
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "order_price": self.orderPrice,
                          "out_trade_no": self.orderPrice,
                          "trade_status": 9000] as [String : Any]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let jsonResource):
                                print("pay success json: \(jsonResource)")
                                let json = JSON(jsonResource)
                                print("info = \(json["info"].stringValue)")
                                completionHandler(true, nil)
                            case .failure(let error):
                                print("pay callback error: \(error)")
                            }
        }
    }

}
