//
//  SoldTicketViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/9.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import MJRefresh

class SoldTicketViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "已购票的漫展"
        
        // refresh
        let headerHandler = #selector(loadTicketExhibition)
        let loadMoreHandler = #selector(loadMore)
        let headerRefresh = MJRefreshHeader(refreshingTarget: self,
                                            refreshingAction: headerHandler)
        let footerRefresh = MJRefreshAutoNormalFooter(refreshingTarget: self,
                                                      refreshingAction: loadMoreHandler)
        footerRefresh?.setTitle("已全部加载", for: .noMoreData)
        tableView?.mj_header = headerRefresh
        tableView?.mj_footer = footerRefresh
        
        tableView?.mj_header.beginRefreshing()
    }
    
    private let exhibition = Exhibition()
    private var exhibitions = [Exhibition]()
    @objc private func loadTicketExhibition() {
        exhibition.soldTicketForExhibitionList(loadMore: false, completionHandler: { [weak self] success, info, exhibitions in
            self?.tableView.mj_header.endRefreshing()
            if success {
                if self != nil {
                    self!.exhibitions = exhibitions
                    self!.tableView.reloadData()
                }
            } else {
                print("load exhibition ticket failure: \(info ?? "no value")")
            }
        })
    }
    
    
    @objc private func loadMore() {
        exhibition.soldTicketForExhibitionList(loadMore: true, completionHandler: { [weak self] success, info, exhibitions in
            self?.tableView.mj_footer.endRefreshing()
            if success {
                if self != nil {
                    self!.exhibitions = exhibitions
                    self!.tableView.reloadData()
                }
            } else {
                print("load more exhibition ticket failure: \(info ?? "no value")")
            }
        })
    }
    
    // MARK: - Helper
    
    private let ticketIdnetifer = "bought ticket identififer"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exhibitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ticketIdnetifer, for: indexPath)
        if let cell = cell as? BoughtTicketCell {
            let ex = self.exhibitions[indexPath.row]
            cell.statusLabel?.text = ex.stauts
            cell.titleLabel?.text = ex.name
        }
        return cell
    }

}
