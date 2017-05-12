//
//  URLAct.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/10.
//  Copyright © 2017年 moelove. All rights reserved.
//

import Foundation

let kHeaderUrl = "https://apiplus.nyato.com"
let kSecretKey = "us8dgf30hjRJGFU21"

struct RequestURL {
    static let kLoginUrlString = "/index.php?app=ios&mod=Member&act=login"
    static let kUserInfoUrlString = "/index.php?app=ios&mod=Member&act=getuinfo"
    static let kExhibitionUrlString = "/index.php?app=ios&mod=Business&act=ex_list"
    static let kTopupRecordUrlString = "/index.php?app=ios&mod=Business&act=recharge_logs"
    static let kSoldExhibitionUrlString = "/index.php?app=ios&mod=Business&act=my_list"
    static let kTicketsUrlString =  "/index.php?app=ios&mod=Business&act=sale_logs"
}

struct ActType {
    static let login = "login"
    static let getuinfo = "getuinfo"
    static let ex_list = "ex_list"
    static let recharge_logs = "recharge_logs"
    static let my_list = "my_list"
    static let sale_logs = "sale_logs"
}

