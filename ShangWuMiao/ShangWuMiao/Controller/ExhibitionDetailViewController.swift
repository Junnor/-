//
//  ExhibitionDetailViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/8.
//  Copyright © 2017年 moelove. All rights reserved.
//
// navigation bar 的设置没弄好

import UIKit
import Kingfisher

class ExhibitionDetailViewController: UIViewController {
    
    var exhibition: Exhibition!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = UIColor.backgroundColor
            collectionView.showsVerticalScrollIndicator = false
        }
    }
    
    // MARK: - View controller lifecycle
    
    fileprivate let constCellCounts = 4
    fileprivate var tickts = [Ticket]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCollectionView()
        setNaviView()
        
        exhibition.requestExhibitionListTickets { [weak self] (success, info, tickts) in
            if success {
                self?.tickts = tickts
                self?.collectionView.reloadData()
            } else {
                print("request exhibition ticket failure: \(info!)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // MARK: - Helper
    
    private func registerCollectionView() {
        collectionView.register(UINib(nibName: "ExHeaderCell", bundle: nil), forCellWithReuseIdentifier: "ExHeaderCellID")
        collectionView.register(UINib(nibName: "ExDescriptionCell", bundle: nil), forCellWithReuseIdentifier: "ExDescriptionCellID")
        collectionView.register(UINib(nibName: "ExInputHintCell", bundle: nil), forCellWithReuseIdentifier: "ExInputHintCellID")
        collectionView.register(UINib(nibName: "ExTicketCell", bundle: nil), forCellWithReuseIdentifier: "ExTicketCellID")
        collectionView.register(UINib(nibName: "ExFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "ExFooterViewID")
    }
    
    private var naviView: CustomNaviBarView!
    private func setNaviView() {
        // custom navigation bar view
        naviView = CustomNaviBarView.naviBarViewFromNib()
        naviView.alpha = 0.0
        
        self.view.insertSubview(naviView, belowSubview: (navigationController?.navigationBar)!)
    }

    @IBAction func buy(_ sender: Any) {
        print("... buy")
    }
    
    // set navigation bar
    private let naviBarHeight: CGFloat = 64
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY > 0 {
            let alpha = min(offsetY/naviBarHeight, 1.0)
            self.naviView.alpha = alpha
        } else {
            self.naviView.alpha = 0.0
        }
    }
}

extension ExhibitionDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return constCellCounts + self.tickts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExHeaderCellID", for: indexPath)
            if let cell = cell as? ExHeaderCell {
                if let url = URL(string: kImageHeaderUrl + self.exhibition.cover!) {
                    let resourcce = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
                    cell.exImageView.kf.setImage(with: resourcce,
                                      placeholder: nil,
                                      options: [.transition(.fade(1))],
                                      progressBlock: nil,
                                      completionHandler: nil)
                    
                    
                    cell.backgroundImageView.kf.setImage(with: resourcce,
                                                 placeholder: nil,
                                                 options: [.transition(.fade(1))],
                                                 progressBlock: nil,
                                                 completionHandler: nil)
                }
                
                cell.nameLabel.text = self.exhibition.name
                cell.presaleLabel.text = self.exhibition.presale_price
                cell.locationLabel.text = self.exhibition.location
                
                let attributedText = NSMutableAttributedString(string: self.exhibition.scene_price)
                attributedText.addAttributes([NSBaselineOffsetAttributeName:0, NSStrikethroughStyleAttributeName: 1], range: NSRange(location: 0, length: NSString(string: self.exhibition.scene_price).length))
                cell.scenePriceLabel.attributedText = attributedText

                let startTime = exhibition.exhibition(stringTime: self.exhibition.start_time, digit: true)
                let endTime = exhibition.exhibition(stringTime: self.exhibition.end_time, digit: true)
                
                cell.timeLabel.text = "\(startTime) - \(endTime)"
            }
            
            return cell
        } else if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExDescriptionCellID", for: indexPath)
            cell.backgroundColor = UIColor.white
            if let cell = cell as? ExDescriptionCell {
                cell.titleLabel.text = self.exhibition.exDescription
            }
            return cell
        } else if indexPath.item == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExDescriptionCellID", for: indexPath)
            cell.backgroundColor = UIColor.backgroundColor
            if let cell = cell as? ExDescriptionCell {
                cell.titleLabel.text = "漫展详细地址：" + self.exhibition.addr
            }
            
            return cell
        } else if indexPath.item == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExInputHintCellID", for: indexPath)
            cell.backgroundColor = UIColor.white
            if let cell = cell as? ExInputHintCell {
                cell.priceButton.addTarget(self, action: #selector(priceChangeAction(sender:)), for: .touchUpInside)
            }
            
            return cell
        }  else  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExTicketCellID", for: indexPath)
            cell.backgroundColor = UIColor.backgroundColor
            if let cell = cell as? ExTicketCell {
                let tickt = tickts[indexPath.item - constCellCounts]
                cell.nameLabel.text = tickt.name
                cell.priceLabel.text = tickt.price
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "ExFooterViewID", for: indexPath)
        
        if let footer = footerView as? ExFooterView, indexPath.section == 0 {
            footer.plusButton.addTarget(self, action: #selector(plusAction), for: .touchUpInside)
            footer.minusButton.addTarget(self, action: #selector(minusAction), for: .touchUpInside)

        }
        return footerView
    }
    
    @objc private func plusAction() {
        print("... plus")
    }
    
    @objc private func minusAction() {
        print("... minus")
    }
    
    @objc private func priceChangeAction(sender: UIButton) {
        print(priceChangeAction)
    }
    
}

extension ExhibitionDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        var height: CGFloat = 0.0
        switch indexPath.row {
        case 0:
            height = collectionView.bounds.height * 2 / 5
        case 1:
            let font = UIFont.systemFont(ofSize: 16)
            let str = self.exhibition.exDescription!
            let tmpHeight = heightForText(text: str, font: font, width: width - 20) + 16
            height = max(tmpHeight, 50)

        case 2:
            let font = UIFont.systemFont(ofSize: 16)
            let str = "漫展详细地址：" + self.exhibition.addr
            let tmpHeight = heightForText(text: str, font: font, width: width - 20) + 16
            height = max(tmpHeight, 50)
        case 3:
            height = 120
        default:
            height = 50
            break
        }
        
        return CGSize(width: width, height: height)
    }
    
    private func heightForText(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: text).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return ceil(rect.height)
    }
}

