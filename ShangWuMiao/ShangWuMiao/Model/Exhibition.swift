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
    
    func requestExhibitionList() {
        let stringPara = stringParameters(actTo: ActType.ex_list)
        let userinfoString = kHeaderUrl + RequestURL.kExhibitionUrlString + stringPara

        let url = URL(string: userinfoString)
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let json):
                                print("exhibition list json: \(json)")
                                if let dic = json as? Dictionary<String, AnyObject> {
                                    print("info: \(String(describing: dic["info"]))")
                                    print("msg: \(String(describing: dic["msg"]))")
                                }
                            case .failure(let error):
                                print("get exhibition data error: \(error)")
                            }                            
        }
    }
    
}
