//
//  ExhibitionTicketTableViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/12.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import MJRefresh
import Kingfisher

class ExhibitionTicketTableViewController: UITableViewController {
    
    var exhibition: Exhibition!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "门票订单"
        
        tableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        
        // refresh
        let headerHandler = #selector(loadTickets)
        let headerRefresh = MJRefreshHeader(refreshingTarget: self,
                                            refreshingAction: headerHandler)
        tableView?.mj_header = headerRefresh
        
        tableView?.mj_header.beginRefreshing()

    }

    private var tickets = [Ticket]()
    private let ticket = Ticket()
    @objc private func loadTickets() {
        ticket.requestTickets(forExhibitionId: exhibition.exid, loadMore: false) { [weak self] (success, info, tickets) in
            self?.tableView.mj_header.endRefreshing()
            if success {
                self?.tickets = tickets
                self?.tableView.reloadData()
                
                if tickets.count >= kDefaultCount {
                    let footerRefresh = MJRefreshAutoNormalFooter(refreshingTarget: self,
                                                                  refreshingAction: #selector(self!.loadMore))
                    footerRefresh?.setTitle("已全部加载", for: .noMoreData)
                    self!.tableView?.mj_footer = footerRefresh
                }
            } else {
                print("load tickets failure: \(String(describing: info))")
            }
        }
    }
    
    @objc private func loadMore() {
        ticket.requestTickets(forExhibitionId: exhibition.exid, loadMore: true) { [weak self] (success, info, tickets) in
            self?.tableView.mj_header.endRefreshing()
            if success {
                self?.tickets = tickets
                self?.tableView.reloadData()
            } else {
                print("load  mre tickets failure: \(String(describing: info))")
            }
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }

    private let ticketIndentifier = "ticket order identifier"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ticketIndentifier, for: indexPath)

        if let cell = cell as? TicketOrderCell {
            let ticket = tickets[indexPath.row]
            cell.titleLabel?.text = ticket.ordertitle
            cell.orderNumberLabel?.text = "定单号: " + ticket.orderid
            cell.phoneLabel?.text = "手机号:" + ticket.tel
            cell.countLabel?.text = "购买: \(ticket.shop_num!)张，"
            
            if let url = URL(string: kHeaderUrl + ticket.cover) {
                let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
                cell.orderImageView.kf.setImage(with: resource)
            }
            
            cell.sendMessageButton.layer.borderWidth = 1
            cell.sendMessageButton.layer.borderColor = UIColor(red: 246/255.0, green: 208/255.0, blue: 121/255.0, alpha: 1.0).cgColor
        }

        return cell
    }

}
