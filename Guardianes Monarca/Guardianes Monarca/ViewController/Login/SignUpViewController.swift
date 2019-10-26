//
//  SignUpViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 9/19/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import GoogleSignIn

class SignUpViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tFName: UITextField!
    @IBOutlet weak var tFLastName: UITextField!
    @IBOutlet weak var tFEmail: UITextField!
    @IBOutlet weak var tFPassword: UITextField!
    @IBOutlet weak var tFConfirmPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTapGesture()
        configureTextFields()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signUpButton(_ sender: Any) {
       validateFields()
    }
    
    func signUpUser (){
        Auth.auth().createUser(withEmail: tFEmail.text!, password: tFPassword.text!) { (result, error) in
           if result != nil{
               print("user created ")
               
            guard let uid = result?.user.uid else{return}
            
            
           let db = Firestore.firestore()
            db.collection("usuarios").document(uid).setData([
                "nombre":self.tFName.text!,
                "apellido":self.tFLastName.text!,
                "email":self.tFEmail.text!,
                "roles":[1]
            ]){ (error:Error?) in
                if let error = error{
                    print("\(error.localizedDescription)")
                }else{
                    print("Document succesfully created and written")
                    self.navigationController?.popToViewController(ofClass: AccountViewController.self)
                }
                
            }
            
           }else{
                print("error")
                self.createAlert(view_controller: self, title: "Error", message: "Ingresa un nombre")
           }
           
       }
    }
    
    func validateFields(){
        if tFName.text == "" {
               createAlert(view_controller: self, title: "Error", message: "Ingresa un nombre")
               return
        }
       if tFLastName.text == "" {
        self.createAlert(view_controller: self, title: "Error", message: "Ingresa un apellido")
           return
       }
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
       
       
       if (self.tFPassword.text != self.tFConfirmPassword.text) {
           
           self.createAlert(view_controller: self, title: "Error", message: "Las contraseñas no coinciden")
           return
       }
        signUpUser()
    }
    
    func isValidEmail(testStr: String) -> Bool {
        //let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailRegEx = "^\\w+([\\.\\+\\-]?\\w+)*@\\w+([\\.-]?\\w+)*(\\.\\w{2,4})+$"
        
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        addObservers()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    private func configureTapGesture(){
        let tapGesture=UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.handleTap))
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
        tFName.delegate=self as? UITextFieldDelegate
        tFLastName.delegate=self as? UITextFieldDelegate
        tFEmail.delegate=self as? UITextFieldDelegate
        tFPassword.delegate=self as? UITextFieldDelegate
        tFConfirmPassword.delegate=self as? UITextFieldDelegate
        
        
    }
    
    
    
    

}
extension UINavigationController {

func popToViewController(ofClass: AnyClass, animated: Bool = true) {
  if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
    popToViewController(vc, animated: animated)
  }
    }
    
}
