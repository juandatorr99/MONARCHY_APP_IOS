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


@objc(LoginViewController)
class LoginViewController: UIViewController,GIDSignInDelegate {
    
    
    
    
    

    
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tFEmail: UITextField!
    @IBOutlet weak var tFPassword: UITextField!
    
    @IBOutlet weak var buttonSignInGoogle: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTapGesture()
        configureTextFields()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
//
        buttonSignInGoogle.layer.cornerRadius=10
        buttonSignInGoogle.layer.masksToBounds=true
        GIDSignIn.sharedInstance().delegate = self
        self.navigationController?.navigationBar.backItem?.title = "Atrás"
    }
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
               
               Auth.auth().signIn(with: credential) { (authResult,error) in
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
                   guard let uid = authResult?.user.uid else{return}
                   let db = Firestore.firestore()
                              db.collection("usuarios").document(uid).setData([
                               "nombre":name,
                                  "apellido":lastName,
                                  "email":email,
                                "roles":[1]
                              ]){ (error:Error?) in
                                  if let error = error{
                                      print("\(error.localizedDescription)")
                                  }else{
                                    print("Document succesfully created and written")
                                    self.navigationController?.popViewController(animated: true)
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
                self.navigationController?.popViewController(animated: false)
            }else{
                let alert = UIAlertController(title: "Credenciales Incorrectas", message: "Revisa tu correo y/o contraseña", preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okButton)
                self.present(alert,animated: true,completion: nil)
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
//        addObservers()
        if CheckInternet.Connection(){
            
        }else{
            createAlert(view_controller: self, title: "Sin Conexion", message: "No hay conexion a Internet")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        removeObservers()
        
    }
    
    private func configureTapGesture(){
        let tapGesture=UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
   
    
    @objc func handleTap(){
        view.endEditing(true)
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
              self.createAlert(view_controller: self, title: "Error", message: "Ingresa su contraseña")
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


