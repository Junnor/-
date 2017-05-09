//
//  LoginViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/8.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire

let isLogin = "isLogin"

let kCommonUrl = "https://apiplus.nyato.com"
let kSecretKey = "us8dgf30hjRJGFU21"
let kLoginRequestUrl = "/index.php?app=ios&mod=Member&act=login"
let kUserInfoUrl = "/index.php?app=ios&mod=Member&act=getuinfo"

class LoginViewController: UIViewController {
    
    @IBOutlet weak var unameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(tapGesture)
    
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Helper
    @IBAction func login(_ sender: UIButton) {
        // test
        let parameters = ["uname": "宅喵报",
                          "password": "1234560"]
        LoginModel.login(parameters: parameters) { [weak self] status in
            if status == 1 {
                self?.performSegue(withIdentifier: "login", sender: nil)
                UserDefaults.standard.setValue("1", forKeyPath: isLogin)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    @objc private func tap() {
        self.unameTextfield.resignFirstResponder()
        self.passwordTextfield.resignFirstResponder()
    }
    
    private func setUI() {
        let cornerRadius = self.unameTextfield.bounds.height/2
        self.view.backgroundColor = UIColor.lightGray
        self.unameTextfield.layer.cornerRadius = cornerRadius
        self.passwordTextfield.layer.cornerRadius = cornerRadius
        self.loginButton.layer.cornerRadius = cornerRadius
        
        let height = self.unameTextfield.bounds.height
        let unameLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: height))
        let passwordLeftView = UIView(frame: unameLeftView.bounds)
        let unameLeftImageView = UIImageView(image: UIImage(named: "ico-uname"))
        let passwordLeftImageView = UIImageView(image: UIImage(named: "ico-pass"))
        unameLeftView.addSubview(unameLeftImageView)
        unameLeftImageView.center = unameLeftView.center
        passwordLeftView.addSubview(passwordLeftImageView)
        passwordLeftImageView.center = passwordLeftView.center

        self.unameTextfield.leftView = unameLeftView
        self.unameTextfield.leftViewMode = .always
        self.passwordTextfield.leftView = passwordLeftView
        self.passwordTextfield.leftViewMode = .always
    }
    
}

// MARK: - Keyboard action
extension LoginViewController {
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.view.frame.origin.y = 0
            } else {
                self.view.frame.origin.y = -50
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}


extension String  {
    var md5: String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate(capacity: digestLen)
        
        return String(format: hash as String)
    }
}
