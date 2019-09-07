//
//  LoginViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 9/3/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController,LoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let login = FBLoginButton()
        view.addSubview(login)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Loged Out")
    }
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil{
            print(error!)
            return
        }else{
            print("Loged In")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}
