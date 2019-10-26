//
//  RecoverPasswordViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 10/10/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit
import FirebaseAuth

class RecoverPasswordViewController: UIViewController {

    @IBOutlet weak var textFieldEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func isValidEmail(testStr: String) -> Bool {
           //let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
           let emailRegEx = "^\\w+([\\.\\+\\-]?\\w+)*@\\w+([\\.-]?\\w+)*(\\.\\w{2,4})+$"
           
           let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
           return emailTest.evaluate(with: testStr)
       }
       

    @IBAction func SendEmailButtonPressed(_ sender: Any) {
        
        validateFields()
            
    }
    func validateFields(){
       
        if !isValidEmail(testStr: textFieldEmail.text!) {
            
            self.createAlert(view_controller: self, title: "Error", message: "Invalid Email Format")
            return
        }
       

       if textFieldEmail.text?.lowercased() == "" {
           
           self.createAlert(view_controller: self, title: "Error", message: "Ingresa un correo")
           return
       }
       
        
        Auth.auth().sendPasswordReset(withEmail: self.textFieldEmail.text!) { error in
            if error != nil {
            self.createAlert(view_controller: self, title: "Error", message: "Ocurrio un error, talvez tu correo no esta en el sistema")
          } else {
                
            self.createAlert(view_controller: self, title: "Exito", message: "Se ha enviado al correo \(String(describing: self.textFieldEmail.text!)) el proceso para recuperar su contraseña")
                
          }
            
        }
        
       
       
    }

}
