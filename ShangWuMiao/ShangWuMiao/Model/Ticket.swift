//
//  Ticket.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/12.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire

class Ticket: NSObject {
    
    var cover: String!
    var ordertitle: String!
    var tel: String!
    var shop_num: String!
    var orderid: String!
    
    override init() {
        // do nothing
        super.init()
    }

    convenience init(id: String, title: String, cover: String, telphone: String, number: String) {
        self.init()
        
        self.orderid = id
        self.ordertitle = title
        self.cover = cover
        self.tel = telphone
        self.shop_num = number
    }
    
    
    fileprivate var ticketPage = 1
    fileprivate var tickets = [Ticket]()
}

extension Ticket {
    
    func requestTickets(forExhibitionId exhibitionId: String, loadMore more: Bool, completionHandler: @escaping (Bool, String?, [Ticket]) -> ()) {
        ticketPage = more ? ticketPage + 1 : 1
        print("page = \(ticketPage)")
        
        let stringPara = stringParameters(actTo: ActType.sale_logs)
        let userinfoString = kHeaderUrl + RequestURL.kTicketsUrlString + stringPara
        
        let url = URL(string: userinfoString)
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "eid": NSString(string: exhibitionId).integerValue,
                          "p": self.ticketPage]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let json):
//                                print("exhibition list json: \(json)")
//                                print("........................................")
                                if let dic = json as? Dictionary<String, AnyObject> {
                                    if let status = dic["result"] as? Int {
                                        if status == 1 {
                                            if let dataArr = dic["data"] as? Array<Dictionary<String, AnyObject>> {
                                                var tmpTickets = [Ticket]()
                                                for data in dataArr {
                                                    // 先这样, 强制转换不好 ！！！
                                                    let orderid = data["orderid"] as! String
                                                    let cover = data["cover"] as! String
                                                    let ordertitle = data["ordertitle"] as! String
                                                    let tel = data["tel"] as! String
                                                    let shop_num = data["shop_num"] as! String

                                                    let ticket = Ticket(id: orderid, title: ordertitle, cover: cover, telphone: tel, number: shop_num)
                                                    
                                                    tmpTickets.append(ticket)
                                                }
                                                
                                                if more {
                                                    for ticket in tmpTickets {
                                                        self.tickets.append(ticket)
                                                    }
                                                } else {
                                                    self.tickets.removeAll()
                                                    self.tickets = tmpTickets
                                                }
                                                
                                                completionHandler(true, nil, self.tickets)
                                            }
                                            return
                                        } else {
                                            let errorInfo = dic["error"] as? String
                                            completionHandler(false, errorInfo, [])
                                        }
                                    }
                                }
                            case .failure(let error):
                                print("get tickets data error: \(error)")
                            }
        }
    }

}
