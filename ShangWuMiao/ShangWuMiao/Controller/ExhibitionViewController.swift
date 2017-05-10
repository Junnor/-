//
//  ExhibitionViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/8.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class ExhibitionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let comicCellId = "ComicCellIdentifer"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = CGSize(width: view.bounds.width, height: 150)
        layout?.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout!
        
        // set navigation bar
        let backImage = UIImage(named: "nav-expoed")
        backImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: backImage!.size.width - 1, bottom: 0, right: 0))
        
        let appearance = UIBarButtonItem.appearance()
        appearance.setBackButtonBackgroundImage(backImage, for: .normal, barMetrics: .default)
        
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }
    
    private let exhibition = Exhibition()
    private var hadExhibition = false
    private var exhibitions = [Exhibition]()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        
        if !hadExhibition {
            print("..load exhibition")
            exhibition.requestExhibitionList(completionHandler: { [weak self] success, info, exhibitions in
                print("..success")
                if success {
                    print("..self: \(self)")

                    if self != nil {
                        self!.hadExhibition = true
                        self!.exhibitions = exhibitions
                        self!.collectionView.reloadData()
                        print("..self: dskfjskhfkfh")

                    }

                } else {
                    print("load exhibition failure: \(info ?? "no value")")
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.exhibitions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: comicCellId, for: indexPath)
        if let cell = cell as? ComicViewCell {
//            cell.comicImageView.image
            let ex = self.exhibitions[indexPath.item]
            cell.titleLabel.text = ex.name
            cell.dateLabel.text = "2017年03月20日 - 07月20日"
            cell.addressLabel.text = ex.addr
        }
        return cell
    }
}





