//
//  ExhibitionDetailViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/8.
//  Copyright © 2017年 moelove. All rights reserved.
//
// navigation bar 的设置没弄好

import UIKit

class ExhibitionDetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.showsHorizontalScrollIndicator = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNaviView()
        scrollView.contentSize = CGSize(width: view.bounds.width, height: 1000)
    }
    
    private var naviView: CustomNaviBarView!
    private func setNaviView() {
        // custom navigation bar view
        naviView = CustomNaviBarView.naviBarViewFromNib()
        naviView.alpha = 0.0
        
        self.view.insertSubview(naviView, belowSubview: (navigationController?.navigationBar)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
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
