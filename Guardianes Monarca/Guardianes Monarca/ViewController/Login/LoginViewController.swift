//
//  LoginViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 9/3/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import Firebase
import FirebaseFirestore
import FBSDKLoginKit

@objc(LoginViewController)
class LoginViewController: UIViewController, LoginButtonDelegate,GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                    withError error: Error!) {
            if let error = error {
                if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                  print("The user has not signed in before or they have since signed out.")
                } else {
                  print("\(error.localizedDescription)")
                }
                
                return
              }
           
           guard let authentication = user.authentication else { return }
           let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,accessToken: authentication.accessToken)
           
           Auth.auth().signIn(with: credential) { (result,error) in
           if let error = error {
               print("Error")
               }
                
                let name = user.profile.givenName!
               let lastName = user.profile.familyName!
                let email = user.profile.email!
                // [START_EXCLUDE]
                NotificationCenter.default.post(
                  name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                  object: nil,
                  userInfo: ["statusText": "Signed in user:\n\(name+lastName)"])
                // [END_EXCLUDE]
               guard let uid = result?.user.uid else{return}
               let db = Firestore.firestore()
                          db.collection("usuarios").document(uid).setData([
                           "nombre":name,
                              "apellido":lastName,
                              "email":email
                          ]){ (error:Error?) in
                              if let error = error{
                                  print("\(error.localizedDescription)")
                              }else{
                                print("Document succesfully created and written")
                                self.navigationController?.popToRootViewController(animated: false)
                              }
                              
                          }
           }
                                                                
              
           
       
          }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // [START_EXCLUDE]
      NotificationCenter.default.post(
        name: Notification.Name(rawValue: "ToggleAuthUINotification"),
        object: nil,
        userInfo: ["statusText": "User has disconnected."])
      // [END_EXCLUDE]
    }
    
    func loginButton(_ loginButton:  FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil{
            print(error!)
            return
        }
        
        print("Succesfully")
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if let error = error {
            print(error)
            return
          }
            
            GraphRequest(graphPath: "/me", parameters: ["fields": "id, first_name,last_name, email"]).start{
                (connection,result,err) in
                if error != nil{
                    print (error!)
                    return
                }
                
                let info = result as! [String : AnyObject]
                
                //Sign in with collections
                guard let uid = authResult?.user.uid else{return}
                let db = Firestore.firestore()
                           db.collection("usuarios").document(uid).setData([
                            "nombre":info["first_name"],
                            "apellido":info["last_name"] as? String,
                               "email":info["email"] as? String
                               
                           ]){ (error:Error?) in
                               if let error = error{
                                   print("\(error.localizedDescription)")
                               }else{
                                   print("Document succesfully created and written")

                                
                               }

                           }
//                
                

                
                
                self.navigationController?.popToRootViewController(animated: false)
            }
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Logged Out of Facebook")
    }
    
    
    
    

    
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginFB: UIView!
    @IBOutlet weak var tFEmail: UITextField!
    @IBOutlet weak var tFPassword: UITextField!
    
    @IBOutlet weak var buttonSignInGoogle: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTapGesture()
        configureTextFields()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        let loginFBButton = FBLoginButton()
        
        loginFB.addSubview(loginFBButton)
        loginFBButton.frame = CGRect(x: 0, y: 0, width: loginFB.frame.width-35, height: loginFB.frame.height)
        loginFBButton.delegate = self
        loginFBButton.permissions = ["email","public_profile "]
        
        buttonSignInGoogle.layer.cornerRadius=10
        buttonSignInGoogle.layer.masksToBounds=true
        GIDSignIn.sharedInstance().delegate = self
    }
    
    @IBAction func buttonLoginPressed(_ sender: Any) {
        validateFields()
    }
    @IBAction func loginG(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
            
    }
    
    
    
    
    func logIn (){
        Auth.auth().signIn(withEmail: tFEmail.text!, password: tFPassword.text!) { (user, error) in
            if user != nil{
                print("login")
                self.navigationController?.popToRootViewController(animated: false)
            }else{
                let alert = UIAlertController(title: "There was a problem", message: nil, preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okButton)
                self.present(alert,animated: true,completion: nil)
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden=true
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    private func configureTapGesture(){
        let tapGesture=UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
   
    
    @objc func handleTap(){
        view.endEditing(true)
    }
    
    //Adding Observers to Show and Hide Keyboard
    func addObservers(){
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil){
            notification in
            self.keyboardWillShow(notification:notification)
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil){
            notification in
            self.keyboardWillHide(notification:notification)
        }
    }
    //Remove Observers
    func removeObservers(){
        NotificationCenter.default.removeObserver(self)
    }
    
    //Methods to handle the keyboarWillShow notification
    func keyboardWillShow(notification:Notification){
        guard let userInfo=notification.userInfo,
            let frame=(userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
                return
        }
        let contentInset=UIEdgeInsets(top:0, left:0,bottom:frame.height,right:0)
        scrollView.contentInset=contentInset
    }
    
    //When keyboard is hidden
    func keyboardWillHide(notification:Notification){
        scrollView.contentInset=UIEdgeInsets.zero
    }
    
    private func configureTextFields(){
        tFEmail.delegate=self as? UITextFieldDelegate
        tFPassword.delegate=self as? UITextFieldDelegate
    }
    
    func validateFields(){
           
           if !isValidEmail(testStr: tFEmail.text!) {
               
               self.createAlert(view_controller: self, title: "Error", message: "Invalid Email Format")
               return
           }
          if tFPassword.text == "" {
              self.createAlert(view_controller: self, title: "Error", message: "Ingresa su peso en kg")
              return
          }

          if tFEmail.text?.lowercased() == "" {
              
              self.createAlert(view_controller: self, title: "Error", message: "Ingresa un correo")
              return
          }
          
           if tFPassword.text == "" {
               self.createAlert(view_controller: self, title: "Error", message: "Ingresa contraseña")
           }
           
           if((tFPassword.text!.count )<8){
               self.createAlert(view_controller: self, title: "Error", message: "La contraseña debe ser de 8 o mas caracteres")
               return
           }
          
          
           logIn()
       }
    
    
    func isValidEmail(testStr: String) -> Bool {
           //let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
           let emailRegEx = "^\\w+([\\.\\+\\-]?\\w+)*@\\w+([\\.-]?\\w+)*(\\.\\w{2,4})+$"
           
           let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
           return emailTest.evaluate(with: testStr)
       }
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


