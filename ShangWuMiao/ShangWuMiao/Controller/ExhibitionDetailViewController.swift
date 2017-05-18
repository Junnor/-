//
//  ExhibitionDetailViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/8.
//  Copyright © 2017年 moelove. All rights reserved.
//
// navigation bar 的设置没弄好
// colection view 的选择处理一团糟

import UIKit
import Kingfisher

class ExhibitionDetailViewController: UIViewController {
    
    var exhibition: Exhibition!
    
    fileprivate let limitLines = 6
    fileprivate let showMoreButtonWithGap: CGFloat = 50
    fileprivate let noMoreButtonWithGap: CGFloat = 20
    fileprivate let limitTextHeight: CGFloat = 170   // (limitetLines * 20 + 50 gap)
    fileprivate var readMore = false
    fileprivate var originalPrice = true
    
    fileprivate weak var phoneTextField: UITextField!
    
    lazy fileprivate var shadowView: UIView = {
        let shadow = UIView()
        shadow.frame = UIScreen.main.bounds
        shadow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textFieldResignFirstResonder)))
        shadow.backgroundColor = UIColor.lightGray
        shadow.alpha = 0.3
        shadow.isHidden = true
        self.view.addSubview(shadow)
        
        return shadow
    }()
    
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
                
                let indexPath = IndexPath(item: 0, section: 1)
                self?.collectionView.selectItem(at: indexPath,
                                                animated: true,
                                                scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
            } else {
                print("request exhibition ticket failure: \(info!)")
            }
        }
    
        // keyboard notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
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
        collectionView.register(UINib(nibName: "ExAddressCell", bundle: nil), forCellWithReuseIdentifier: "ExAddressCellID")
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

    @objc fileprivate func textFieldResignFirstResonder() {
        shadowView.isHidden = true
        phoneTextField.resignFirstResponder()
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

// MARK: - Keyboard action
extension ExhibitionDetailViewController {
    func keyboardNotification(notification: NSNotification) {
        print("keyboardNotification")
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            print("...end frame = \(endFrame!)")
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                print("... 0")

                self.collectionView.frame.origin.y = 0
            } else {
                print("... -50")
                self.collectionView.frame.origin.y = -50
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0.5),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}


extension ExhibitionDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? constCellCounts : tickts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
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
                    
                    if shouldShowMoreButton() {
                        cell.moreButton.addTarget(self, action: #selector(moreWords), for: .touchUpInside)
                        cell.moreButton.setTitle(readMore ? "点击收起" : "展开更多", for: .normal)
                        cell.titleLabel.numberOfLines = readMore ? 0 : limitLines
                    } else {
                        cell.moreButton.isHidden = true
                        cell.bottonConstraint.constant = 8
                    }
                    
                }
                return cell
            } else if indexPath.item == 2 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExAddressCellID", for: indexPath)
                cell.backgroundColor = UIColor.backgroundColor
                if let cell = cell as? ExAddressCell {
                    cell.titleLabel.text = "漫展详细地址：" + self.exhibition.addr
                }
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExInputHintCellID", for: indexPath)
                cell.backgroundColor = UIColor.white
                if let cell = cell as? ExInputHintCell {
                    cell.phoneTextField.delegate = self
                    self.phoneTextField = cell.phoneTextField   // weak
                    
                    cell.priceButton.addTarget(self, action: #selector(priceChangeAction(sender:)), for: .touchUpInside)
                    cell.priceButton.setTitle(originalPrice ? "显示代理价格" : "返回原价", for: .normal)
                    if originalPrice {
                        cell.priceButton.backgroundColor = UIColor.backgroundColor
                        cell.priceButton.layer.borderWidth = 1.0
                        cell.priceButton.layer.borderColor = UIColor.red.cgColor
                        cell.priceButton.setTitleColor(UIColor.red, for: .normal)
                    } else {
                        cell.priceButton.backgroundColor = UIColor.red
                        cell.priceButton.setTitleColor(UIColor.white, for: .normal)
                    }
                }
                
                return cell
            }
        } else  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExTicketCellID", for: indexPath)
            if let cell = cell as? ExTicketCell {
                if tickts.count >= 1 {
                    let tickt = tickts[indexPath.item]
                    cell.nameLabel?.text = tickt.name
                    cell.priceLabel?.text = originalPrice ? tickt.price : tickt.proxy_price
                    
                    cell.layer.borderWidth = 1.0
                    cell.layer.borderColor = UIColor.red.cgColor
                    
                    if cell.isSelected {
                        cell.nameLabel?.textColor = UIColor.white
                        cell.priceLabel?.textColor = UIColor.white
                        cell.backgroundColor = UIColor.red
                        
                    } else {
                        cell.nameLabel?.textColor = UIColor.red
                        cell.priceLabel?.textColor = UIColor.red
                        cell.backgroundColor = UIColor.backgroundColor
                    }
                    
                    if !originalPrice && !cell.isSelected {
                        cell.priceLabel?.textColor = UIColor.yellow
                    }
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "ExFooterViewID", for: indexPath)
        
        if let footer = footerView as? ExFooterView, indexPath.section == 1 {
            footer.plusButton.addTarget(self, action: #selector(plusAction), for: .touchUpInside)
            footer.minusButton.addTarget(self, action: #selector(minusAction), for: .touchUpInside)

        }
        return footerView
    }
    
    fileprivate func shouldShowMoreButton() -> Bool {
        let font = UIFont.systemFont(ofSize: 16)
        let str = self.exhibition.exDescription!
        return heightForText(text: str,
                             font: font,
                             width: collectionView.bounds.width - 30) + 40 > limitTextHeight
    }
    
    @objc private func moreWords() {
        self.readMore = !self.readMore
        self.collectionView.reloadData()
    }
    
    @objc private func plusAction() {
        print("... plus")
    }
    
    @objc private func minusAction() {
        print("... minus")
    }
    
    @objc private func priceChangeAction(sender: UIButton) {
        originalPrice = !originalPrice
        
        let lastSelectedIndex = collectionView.indexPathsForSelectedItems?.first

        self.collectionView.reloadData()
        
        self.collectionView.selectItem(at: lastSelectedIndex, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
    }
}

extension ExhibitionDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ExTicketCell {
            cell.nameLabel?.textColor = UIColor.white
            cell.priceLabel?.textColor = UIColor.white
            cell.backgroundColor = UIColor.red
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ExTicketCell {
            cell.nameLabel?.textColor = UIColor.red
            cell.priceLabel?.textColor = UIColor.red
            cell.backgroundColor = UIColor.backgroundColor
            
            if !originalPrice {
                cell.priceLabel?.textColor = UIColor.yellow
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return section == 1 ? UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) : UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return section == 1 ? 30 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return section == 0 ? CGSize.zero : CGSize(width: collectionView.bounds.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = collectionView.bounds.width
        var height: CGFloat = 0.0
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                height = collectionView.bounds.height * 2 / 5
            case 1:
                let font = UIFont.systemFont(ofSize: 16)
                let str = self.exhibition.exDescription!
                var tmpHeight = heightForText(text: str, font: font, width: width - 30)
                
                if shouldShowMoreButton() {
                    tmpHeight += showMoreButtonWithGap
                    height = readMore ? tmpHeight : limitTextHeight
                } else {
                    tmpHeight += noMoreButtonWithGap
                    height = max(tmpHeight, 50)
                }
                
            case 2:
                let font = UIFont.systemFont(ofSize: 16)
                let str = "漫展详细地址：" + self.exhibition.addr
                let tmpHeight = heightForText(text: str, font: font, width: width - 30) + 16
                height = max(tmpHeight, 50)
            default:
                height = 120
                break
            }
        } else {
            width -= 20
            height = 40
        }
        
        return CGSize(width: width, height: height)
    }
    
    fileprivate func heightForText(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: text).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return ceil(rect.height)
    }
}

extension ExhibitionDetailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        shadowView.isHidden = false
    }
}

