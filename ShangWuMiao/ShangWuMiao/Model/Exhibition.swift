//
//  Exhibition.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/10.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire


class Exhibition: NSObject {
    
    // for normal exhibition
    var addr: String!
    var cover: String!
    var start_time: String!
    var end_time: String!
    var name: String!
    var exid: String!
    var location: String!
    var exDescription: String!
    
    // for ticket exhibition
    var stauts: String!
    
    // for top up list
    var orderid: String!
    var orderTitle: String!
    var order_price: String!
    var pay_status: String!
    
    override init() {
        // do nothing
        super.init()
    }
    
    convenience init(id: String,
         cover: String,
         name: String,
         exDescription: String,
         addr: String,
         location: String,
         start_time: String,
         end_time: String) {
        
        self.init()
        
        self.exid = id
        self.cover = cover
        self.name = name
        self.exDescription = exDescription
        self.location = location
        self.start_time = start_time
        self.end_time = end_time
        self.addr = addr
    }
    
    
    // For more data 
    fileprivate var exhibitionPage = 1
    fileprivate var ticketPage = 1
    fileprivate var topupListPage = 1

    fileprivate var exhibitions = [Exhibition]()
}

extension Exhibition {    
    // digit == true -> 05-11 10:00
    func exhibition(stringTime time: String, digit: Bool) -> String {
        let value = NSString(string: time).doubleValue
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        if digit {
            formatter.dateFormat = "MM-dd HH:mm"
        } else {
            formatter.dateFormat = "yyyy年MM月dd日"
        }
        let date = Date(timeIntervalSince1970: value)

        return formatter.string(from: date)
    }
}

// Data request
extension Exhibition {
    
    func requestSoldTicketForExhibitionList(loadMore more: Bool, completionHandler: @escaping (Bool, String?, [Exhibition]) -> ()) {
        ticketPage = more ? ticketPage + 1 : 1
        print("page = \(ticketPage)")
        
        let stringPara = stringParameters(actTo: ActType.my_list)
        let userinfoString = kHeaderUrl + RequestURL.kSoldExhibitionUrlString + stringPara
        
        let url = URL(string: userinfoString)
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "p": self.ticketPage]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let json):
                                //                                 print("exhibition list json: \(json)")
                                //                                 print("........................................")
                                if let dic = json as? Dictionary<String, AnyObject> {
                                    if let status = dic["result"] as? Int {
                                        if status == 1 {
                                            if let dataArr = dic["data"] as? Array<Dictionary<String, AnyObject>> {
                                                var tmpExhibitions = [Exhibition]()
                                                for data in dataArr {
                                                    // 先这样, 强制转换不好 ！！！
                                                    let addr = data["addr"] as! String
                                                    let cover = data["cover"] as! String
                                                    let start_time = data["start_time"] as! String
                                                    let end_time = data["end_time"] as! String
                                                    let name = data["name"] as! String
                                                    let exid = data["eid"] as! String
                                                    let location = data["location"] as! String
                                                    let description = data["description"] as! String
                                                    
                                                    let ex = Exhibition(id: exid,
                                                                        cover: cover,
                                                                        name: name,
                                                                        exDescription: description,
                                                                        addr: addr,
                                                                        location: location,
                                                                        start_time: start_time,
                                                                        end_time: end_time)
                                                    
                                                    // for ticket exhibition
                                                    let status = data["status"] as! String
                                                    ex.stauts = status

                                                    tmpExhibitions.append(ex)
                                                }
                                                
                                                if more {
                                                    for exhibition in tmpExhibitions {
                                                        self.exhibitions.append(exhibition)
                                                    }
                                                } else {
                                                    self.exhibitions.removeAll()
                                                    self.exhibitions = tmpExhibitions
                                                }
                                                
                                                completionHandler(true, nil, self.exhibitions)
                                            }
                                            return
                                        } else {
                                            let errorInfo = dic["error"] as? String
                                            completionHandler(false, errorInfo, [])
                                        }
                                    }
                                }
                            case .failure(let error):
                                print("get exhibition data error: \(error)")
                            }
        }
    }

    // true for more, false for page 0 or refresh
    func requestExhibitionList(loadMore: Bool, completionHandler: @escaping (Bool, String?, [Exhibition]) -> ()) {
        exhibitionPage = loadMore ? exhibitionPage + 1 : 1
        print("page = \(exhibitionPage)")
        
        let stringPara = stringParameters(actTo: ActType.ex_list)
        let userinfoString = kHeaderUrl + RequestURL.kExhibitionUrlString + stringPara
        
        let url = URL(string: userinfoString)
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "p": self.exhibitionPage]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let json):
//                                 print("exhibition list json: \(json)")
//                                 print("........................................")
                                if let dic = json as? Dictionary<String, AnyObject> {
                                    if let status = dic["result"] as? Int {
                                        if status == 1 {
                                            if let dataArr = dic["data"] as? Array<Dictionary<String, AnyObject>> {
                                                var tmpExhibitions = [Exhibition]()
                                                for data in dataArr {
                                                    // 先这样, 强制转换不好 ！！！
                                                    let addr = data["addr"] as! String
                                                    let cover = data["cover"] as! String
                                                    let start_time = data["start_time"] as! String
                                                    let end_time = data["end_time"] as! String                                                    
                                                    let name = data["name"] as! String
                                                    let exid = data["eid"] as! String
                                                    let location = data["location"] as! String
                                                    let description = data["description"] as! String
                                                    
                                                    let ex = Exhibition(id: exid,
                                                                        cover: cover,
                                                                        name: name,
                                                                        exDescription: description,
                                                                        addr: addr,
                                                                        location: location,
                                                                        start_time: start_time,
                                                                        end_time: end_time)
                                                    tmpExhibitions.append(ex)
                                                }
                                                
                                                if loadMore {
                                                    for exhibition in tmpExhibitions {
                                                        self.exhibitions.append(exhibition)
                                                    }
                                                } else {
                                                    self.exhibitions.removeAll()
                                                    self.exhibitions = tmpExhibitions
                                                }
                                                
                                                completionHandler(true, nil, self.exhibitions)
                                            }
                                            return
                                        } else {
                                            let errorInfo = dic["error"] as? String
                                            completionHandler(false, errorInfo, [])
                                        }
                                    }
                                }
                            case .failure(let error):
                                print("get exhibition data error: \(error)")
                            }
        }
    }
    
    

}
