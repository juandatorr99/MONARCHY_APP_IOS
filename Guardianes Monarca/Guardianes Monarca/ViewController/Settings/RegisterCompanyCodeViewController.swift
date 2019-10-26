//
//  RegisterCompanyCodeViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 10/24/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterCompanyCodeViewController: UIViewController {
    @IBOutlet weak var tFCodigoCompañia: UITextField!
    @IBOutlet weak var editCompanyLabel: UILabel!
    @IBOutlet weak var buttonRegister: UIButton!
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    var info:[String : AnyObject]?=[:]
    override func viewWillAppear(_ animated: Bool) {
        getUserInfo()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTapGesture()

        // Do any additional setup after loading the view.
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
                            
                            self.tFCodigoCompañia.text = self.info!["codigo"] as? String ?? ""
                            self.editCompanyLabel.text = "Editar Codigo de Compañia"
                            self.buttonRegister.setTitle("Editar", for: .normal)
                        } else {
                            print("Document does not exist")
                            
                        }
                    }
                }
        }
    @IBAction func registerCodePressed(_ sender: Any) {
        let code = self.tFCodigoCompañia.text
        if tFCodigoCompañia.text == "\(String(describing: info?["codigo"]) )"{
            navigationController?.popViewController(animated: true)
        }else if  tFCodigoCompañia.text == ""{
            self.createAlert(view_controller: self, title: "Campo Vacio", message: "Debes entrar la informacion a guardar")
        }else{
            if let user = user {
               
               let uid = user.uid
               let actualUser = db.collection("usuarios").document(uid)
                
               let documentRef = db.collection("patrocinadores").document(code!)
            
                documentRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                
                                actualUser.setData([ "codigo": code! ], merge: true)
                                
                                
                                
                            }else{
                                self.createAlert(view_controller: self, title: "Aviso", message: "El codigo registrado no existe" )
                                }
                                
                            }
                
                        }

                    
                
                
            }
        }
        
    }
    
