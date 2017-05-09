//
//  MeViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/9.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit


class AvatarCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
}

class MoneyCell: UITableViewCell {
    @IBOutlet weak var moneyLabel: UILabel!
}

class DetailCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}

class MeViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 4
        } else {
            return 1
        }
    }
    
    private enum Identifer: String {
        case avatar = "avatarCellIdentifier"
        case money = "moneyCellIdentifier"
        case detail = "detailCellIdentifier"
    }

    private enum TitleText: String {
        case sold = "已售出门票"
        case topUp = "充值记录"
        case feedback = "问题反馈"
        case delegate = "代理售票相关"
        case signOut = "退出账号"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // identifier
        var identifer = Identifer.detail.rawValue
        if indexPath.section == 0 {
            identifer = indexPath.row == 0 ? Identifer.avatar.rawValue : Identifer.money.rawValue
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifer, for: indexPath)
        cell.selectionStyle = .none
        
        // text and text color
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = cell as! AvatarCell
                cell.usernameLabel?.text = "DQ"
                cell.levelLabel?.text = "normal"
            } else {
                let cell = cell as! MoneyCell
                cell.moneyLabel?.text = "12344.0"
            }
        } else {
            let cell = cell as! DetailCell
            if indexPath.section == 1 {
                var text = ""
                switch indexPath.row {
                case 0: text = TitleText.sold.rawValue
                case 1: text = TitleText.topUp.rawValue
                case 2: text = TitleText.feedback.rawValue
                case 3: text = TitleText.delegate.rawValue
                default: break
                }
                cell.titleLabel.text = text
                cell.titleLabel.textColor = UIColor.black
            } else {
                cell.titleLabel.text = TitleText.signOut.rawValue
                cell.titleLabel.textColor = UIColor.red
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section == 0 && indexPath.row == 0) ? 180 : 50
    }

}
