//
//  AccountViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 9/25/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FBSDKLoginKit

class AccountViewController: UIViewController {

    @IBOutlet weak var labelFirstName: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var tFEventCodes: UITextField!
    @IBOutlet weak var registerEventOutlet: UIButton!
    @IBOutlet weak var registerKitOutlet: UIButton!
    @IBOutlet weak var tFKitCode: UITextField!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var account:Int=0
    var userInformation:[String:AnyObject] = [:]
    override func viewDidLoad() {
        
        super.viewDidLoad()
        getUserInfo()
        configureTapGesture()
        registerEventOutlet.layer.cornerRadius = 0.5 * registerEventOutlet.bounds.size.width
        registerEventOutlet.clipsToBounds = true
    registerKitOutlet.layer.cornerRadius=0.5*registerKitOutlet.bounds.size.width
        registerKitOutlet.clipsToBounds = true
        
        self.navigationController?.navigationBar.backItem?.title = "Atrás"
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
       activityIndicator.center = self.view.center
       activityIndicator.hidesWhenStopped = true
       activityIndicator.style = UIActivityIndicatorView.Style.gray
       
       view.addSubview(activityIndicator)
       activityIndicator.startAnimating()
       if CheckInternet.Connection(){
                  
              }else{
                  createAlert(view_controller: self, title: "Sin Conexion", message: "No hay conexion a Internet")
        activityIndicator.stopAnimating()
              }
        getUserInfo()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        activityIndicator.stopAnimating()
    }
    private func configureTapGesture(){
           let tapGesture=UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleTap))
           view.addGestureRecognizer(tapGesture)
       }
       
      
       
       @objc func handleTap(){
           view.endEditing(true)
       }
    @IBAction func registerToEvent(_ sender: Any) {
        activityIndicator.startAnimating()
        let code = tFEventCodes.text
        if code=="" {
            activityIndicator.stopAnimating()
            createAlert(view_controller: self, title: "Error", message: "Entra un codigo valido")
            return
        }
        let db = Firestore.firestore()
        let docRef = db.collection("eventos").document(code!)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                Model.sharedInstance.addPoints(pointsToAdd: 500)
                self.activityIndicator.stopAnimating()
                self.createAlert(view_controller: self, title: "Exito", message: "El evento fue registrado y haz ganado 500 puntos\nGracias por tu apoyo!")
            } else {
                self.activityIndicator.stopAnimating()
                self.createAlert(view_controller: self, title: "Error", message: "El evento no existe")
            }
        }
        
    }
   
    @IBAction func registerMonarchKit(_ sender: Any) {
        activityIndicator.startAnimating()
        let code = tFKitCode.text
        if code=="" {
            activityIndicator.stopAnimating()
            createAlert(view_controller: self, title: "Error", message: "Entra un codigo valido")
            return
        }
        let db = Firestore.firestore()
        let docRef = db.collection("paquetes").document(code!)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                let infoKit = dataDescription! as [String : AnyObject]
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(infoKit)")
                if infoKit["registrado"] as! Bool{
                    self.activityIndicator.stopAnimating()
                    self.createAlert(view_controller: self, title: "Error", message: "El kit ya ha sido registrado")
                }else{
                    Model.sharedInstance.addPoints(pointsToAdd: 500)
                    docRef.setData([ "registrado": true ], merge: true)
                    self.activityIndicator.stopAnimating()
                    self.createAlert(view_controller: self, title: "Exito", message: "El paquete monarca fue registrado y haz ganado 500 puntos\nGracias por tu apoyo!")
                }
                
            } else {
                self.activityIndicator.stopAnimating()
                self.createAlert(view_controller: self, title: "Error", message: "El paquete monarca no existe")
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        getUserInfo()
        if (Auth.auth().currentUser==nil){
            logInButton.setTitle("Iniciar Sesión", for: .normal)
            
        }else{
            logInButton.setTitle("Cerrar Sesión", for: .normal)
            
        }
    }
    @IBAction func buttonLoginLogoutPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        if Auth.auth().currentUser == nil{
            performSegue(withIdentifier: "loginSegue", sender: self)
        }else{
             do{
                    try Auth.auth().signOut()
        //            self.performSegue(withIdentifier: "Login", sender: self)
                    //
                    getUserInfo()
                    logInButton.setTitle("Iniciar Sesión", for: .normal)
                activityIndicator.stopAnimating()
                    }
                    catch{
                        activityIndicator.stopAnimating()
                        createAlert(view_controller: self, title: "Error", message: "Couldnt log out")
                        print("Couldnt log out")
                    }
                    GIDSignIn.sharedInstance()?.signOut()
                    
                    
                     let loginManager = LoginManager()
                    loginManager.logOut() // this is an instance function
            
        }
    }
    func getUserInfo() {
        var info:[String : AnyObject]?=[:]
            let db = Firestore.firestore()
            let user = Auth.auth().currentUser
            if let user = user {
                
              // The user's ID, unique to the Firebase project.
              // Do NOT use this value to authenticate with your backend server,
              // if you have one. Use getTokenWithCompletion:completion: instead.
                let uid = user.uid
                let actualUser = db.collection("usuarios").document(uid)

                
                actualUser.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data()
                        info = dataDescription! as [String : AnyObject]
                        if(info?["puntos"]==nil){
                            self.pointsLabel.text = "0"
                        }else{
                        self.pointsLabel.text = String(describing:info!["puntos"]! )
                        }
                        self.labelFirstName.text = info!["nombre"] as! String
                        self.labelName.text = "\(String(describing: info!["nombre"] as! String )) \(String(describing: info!["apellido"] as! String ))"
                        print(info!["puntos"] )
                        
                        self.activityIndicator.stopAnimating()
                    } else {
                        print("Document does not exist")
                        self.activityIndicator.stopAnimating()
                        
                    }
                }
               
            }else{
                self.pointsLabel.text = "N/A"
                self.labelFirstName.text = "Invitado"
                self.labelName.text = "Usuario No Registrado"
                activityIndicator.stopAnimating()
        }
        
        
    }
    
    
    
    /*
    // MARK: - Navigation

    
    */

}
