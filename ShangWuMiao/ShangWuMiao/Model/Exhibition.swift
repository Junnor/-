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
    
    var addr: String!
    var cover: String!
    var start_time: String!
    var end_time: String!
    var name: String!
    var exid: String!
    var location: String!
    var exDescription: String!
    
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
    fileprivate var page = 0
}

// Data request
extension Exhibition {
    
    func requestExhibitionList(completionHandler: @escaping (Bool, String?, [Exhibition]) -> ()) {
        let stringPara = stringParameters(actTo: ActType.ex_list)
        let userinfoString = kHeaderUrl + RequestURL.kExhibitionUrlString + stringPara
        
        let url = URL(string: userinfoString)
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue, "p": self.page]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let json):
//                                print("exhibition list json: \(json)")
                                
                                if let dic = json as? Dictionary<String, AnyObject> {
                                    if let status = dic["result"] as? Int {
                                        if status == 1 {
                                            if let dataArr = dic["data"] as? Array<Dictionary<String, AnyObject>> {
                                                var exhibitions = [Exhibition]()
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
                                                    exhibitions.append(ex)
                                                }
                                                completionHandler(true, nil, exhibitions)
                                            }
                                            return
                                        } else {
                                            let info = dic["info"] as! String
                                            completionHandler(false, info, [])
                                        }
                                    }
                                }
                            case .failure(let error):
                                print("get exhibition data error: \(error)")
                            }                            
        }
    }
}
