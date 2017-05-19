//
//  TopupViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/9.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class TopupViewController: UIViewController {
    
    @IBOutlet weak var mcoinsLabel: UILabel!
    @IBOutlet weak var mcoinsSumLabel: UILabel!
    @IBOutlet weak var sumIndicatorLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    fileprivate let userPay = UserPay()
    fileprivate let topupIdentifier = "top up identifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "充值喵币"

        mcoinsLabel?.text = "\(User.shared.mcoins)"
    }
    
    fileprivate var currentMcoinsCount = 10 {
        didSet {
            mcoinsSumLabel?.text = "\(currentMcoinsCount)"
            sumIndicatorLabel?.text = "\(currentMcoinsCount)"
        }
    }
    
    @IBAction func mcoinsHundredPlusAction(_ sender: Any) {
        currentMcoinsCount += 100
    }

    @IBAction func mcoinsTenPlusAction(_ sender: Any) {
        currentMcoinsCount += 10
    }
    
    @IBAction func mcoinsMinusAction(_ sender: Any) {
        if currentMcoinsCount == 10 {
            return
        } else {
            currentMcoinsCount -= 10
        }
    }
}

extension TopupViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:topupIdentifier, for: indexPath)
        cell.selectionStyle = .none
        if let cell = cell as? TopupCell {
            let image = indexPath.row == 0 ? #imageLiteral(resourceName: "pay-alipay") : #imageLiteral(resourceName: "pay-wenxin")
            let title = indexPath.row == 0 ? "使用支付宝支付" : "使用微信支付"
            cell.payImageView?.image = image
            cell.titleLabel?.text = title
            
        }
        return cell
    }
}

extension TopupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {   // alipay
            print("using alipay")
            userPay.pay(withType: Pay.alipay,
                        orderPrice: Float(currentMcoinsCount),
                        completionHandler: { (success, info) in
                
            })
        } else {  // wechat
            print("using wechat")
            userPay.pay(withType: Pay.wechat,
                        orderPrice: Float(currentMcoinsCount),
                        completionHandler: { (success, info) in
      
            })
        
        }
    }
}
