//
//  EditarPerfilViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 10/24/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class EditProfileViewController: UIViewController {
    @IBOutlet weak var tFFirstName: UITextField!
    @IBOutlet weak var tFLastName: UITextField!
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    var info:[String : AnyObject]?=[:]
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTapGesture()
        getUserInfo()
    }
    
    private func configureTapGesture(){
           let tapGesture=UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleTap))
           view.addGestureRecognizer(tapGesture)
       }
       
      
       
       @objc func handleTap(){
           view.endEditing(true)
       }
    func getUserInfo() {
                if let user = user {
                    
                    let uid = user.uid
                    let actualUser = db.collection("usuarios").document(uid)
                    
                    actualUser.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let dataDescription = document.data()
                            self.info = dataDescription! as [String : AnyObject]
                            
                            self.tFFirstName.text = self.info!["nombre"] as! String
                            self.tFLastName.text = "\(String(describing: self.info!["apellido"] as! String ))"
                        } else {
                            print("Document does not exist")
                            
                        }
                    }
                }
        }

    @IBAction func saveProfilePressed(_ sender: Any) {
        if self.tFLastName!.text == "\(info!["apellido"])" && self.tFFirstName!.text == "\(info!["nombre"])"  {
            navigationController?.popViewController(animated: true)
        }else if self.tFLastName.text == "" || tFFirstName.text == "" {
            createAlert(view_controller: self, title: "Error", message: "Debes de llenar todos los campos para hacer los cambios")
        }
        else{
            if let user = user {
               
               let uid = user.uid
               let actualUser = db.collection("usuarios").document(uid)
                   
                actualUser.setData([ "nombre": self.tFFirstName.text! ], merge: true)
                actualUser.setData([ "apellido": self.tFLastName.text! ], merge: true)
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
