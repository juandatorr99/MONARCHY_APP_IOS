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

    @IBOutlet weak var buttonRewards: UIButton!
    @IBOutlet weak var buttonSponsors: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var pointLevelNeedLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var labelFirstName: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var tFEventCodes: UITextField!
    @IBOutlet weak var registerEventOutlet: UIButton!
    @IBOutlet weak var registerKitOutlet: UIButton!
    @IBOutlet weak var tFKitCode: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var account:Int=0
    var userInformation:[String:AnyObject] = [:]
    var points:Int=0
    var total:Float=0
    var level:String=""
    var difference:Float=0
    var nextLevel:String=""
    var allEvents:[String]=[]
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
       getUserInfo()
        buttonRewards.layer.cornerRadius = 10
        buttonRewards.layer.masksToBounds=true
        buttonSponsors.layer.cornerRadius = 10
        buttonSponsors.layer.masksToBounds=true
       if (Auth.auth().currentUser==nil){
           logInButton.setTitle("Iniciar Sesión", for: .normal)
           
       }else{
           logInButton.setTitle("Cerrar Sesión", for: .normal)
           
       }
        
        progressView.layer.cornerRadius = 5
        progressView.clipsToBounds = true
        progressView.layer.sublayers![1].cornerRadius = 5
        progressView.subviews[1].clipsToBounds = true
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
    @IBAction func rewardsButtonPressed(_ sender: Any) {
        if Auth.auth().currentUser==nil{
            createAlert(view_controller: self, title: "Error", message: "Debes iniciar sesion para ver las recompensas que puedes obtener")
        }else{
            performSegue(withIdentifier: "rewards", sender: self)
        }
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
        getUserInfo()
        let code = tFEventCodes.text
        if Auth.auth().currentUser==nil{
            activityIndicator.stopAnimating()
            createAlert(view_controller: self, title: "Error", message: "Debes estar ingresado con un usario primero")
            return
        }
        if code=="" {
            activityIndicator.stopAnimating()
            createAlert(view_controller: self, title: "Error", message: "Entra un codigo valido")
            return
        }
        if allEvents.contains(code!){
            activityIndicator.stopAnimating()
            createAlert(view_controller: self, title: "Error", message: "El codigo ya fue registrado")
            print(allEvents)
            return
        }
        print(allEvents)
        
        let db = Firestore.firestore()
        let docRef = db.collection("eventos").document(code!)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                Model.sharedInstance.addPoints(pointsToAdd: 300)
                let db = Firestore.firestore()
                let user = Auth.auth().currentUser
                if let user = user {
                    let uid = user.uid
                    let actualUser = db.collection("usuarios").document(uid)
                    actualUser.getDocument { (document, error) in
                        if let document = document, document.exists {
                            actualUser.updateData([
                                "eventos": FieldValue.arrayUnion([code!])
                            ])
                    }

                
                    }}

                
                self.activityIndicator.stopAnimating()
                self.createAlert(view_controller: self, title: "Exito", message: "El evento fue registrado y haz ganado 300 puntos\nGracias por tu apoyo!")
            } else {
                self.activityIndicator.stopAnimating()
                self.createAlert(view_controller: self, title: "Error", message: "El evento no existe")
            }
        }
        
    }
    func setProgressView(){
        
    }
    @IBAction func registerMonarchKit(_ sender: Any) {
        activityIndicator.startAnimating()
        let code = tFKitCode.text
        if Auth.auth().currentUser==nil{
            activityIndicator.stopAnimating()
            createAlert(view_controller: self, title: "Error", message: "Debes estar ingresado con un usario primero")
            return
        }
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
                    Model.sharedInstance.addPoints(pointsToAdd: 200)
                    docRef.setData([ "registrado": true ], merge: true)
                    self.activityIndicator.stopAnimating()
                    self.createAlert(view_controller: self, title: "Exito", message: "El paquete monarca fue registrado y haz ganado 200 puntos\nGracias por tu apoyo!")
                }
                
            } else {
                self.activityIndicator.stopAnimating()
                self.createAlert(view_controller: self, title: "Error", message: "El paquete monarca no existe")
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    //Methods to handle the keyboarWillShow notification
       func keyboardWillShow(sender:NSNotification){
          let info = sender.userInfo!
        var keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
          bottomConstraint.constant = keyboardSize - bottomLayoutGuide.length

        let duration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue

          UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
       }
    
//    func addObservers(){
//        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil){
//            notification in
//            self.keyboardWillShow(notification:notification as NSNotification)
//        }
//        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil){
//            notification in
//            self.keyboardWillHide(notification:notification)
//        }
//    }
    //When keyboard is hidden
       func keyboardWillHide(sender:NSNotification){
        let info = sender.userInfo!
        let duration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        bottomConstraint.constant = 0

        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
        
       }
    //Remove Observers
//    func removeObservers(){
//        NotificationCenter.default.removeObserver(self)
//    }
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
                            self.points=0
                        }else{
                        
                        self.pointsLabel.text = String(describing:info!["puntos"]! )
                        self.points=info!["puntos"] as! Int
                        }
                        if(info?["idCompania"]==nil){
                            self.companyLabel.text=""
                       }else{
                            let documentRef = db.collection("patrocinadores").document(info!["idCompania"] as! String)
                                   
                           documentRef.getDocument { (document, error) in
                                       if let document = document, document.exists {
                                           
                                        let dataDescription = document.data()
                                        let infoPatrocinios = dataDescription! as [String : AnyObject]
                                        self.companyLabel.text=infoPatrocinios["nombre"] as! String
                                           
                                           
                            }
                            
                            }
                        }
    
                        
                        self.getLevel(pointsUser: self.points)
                        self.levelLabel.text=self.level
                        self.progressView.progress = Float(self.difference/self.total)
                        print(self.difference/self.total)
                        self.progressView.setProgress(self.progressView.progress, animated: true)
                        self.pointLevelNeedLabel.text = "\(Int(self.total-self.difference)) puntos restantes para nivel \(self.nextLevel)."
                        
                        self.labelFirstName.text = info!["nombre"] as! String
                        self.labelName.text = "\(String(describing: info!["nombre"] as! String )) \(String(describing: info!["apellido"] as! String ))"
                        if info!["eventos"] as? [String]==nil{
                            
                        }else{
                            self.allEvents=info!["eventos"] as! [String]
                        }
                        
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
    
    func getLevel(pointsUser:Int){
        if pointsUser<500{
            total=500
            level="Principiante"
            difference=Float(pointsUser)
            nextLevel="Huevo"
        }else if pointsUser>=500&&pointsUser<2000{
            total=1500
            level="Huevo"
            difference=Float(pointsUser-500)
            nextLevel="Oruga"
        }else if pointsUser>=2000&&pointsUser<8000{
            total=6000
            level="Oruga"
            difference=Float(pointsUser-2000)
            nextLevel="Capullo"
        }else if pointsUser>=8000&&pointsUser<32000{
            total=24000
            level="Capullo"
            difference=Float(pointsUser-8000)
            nextLevel="Mariposa Monarca"
        }else if pointsUser>=32000&&pointsUser<128000{
            total=96000
            level="Mariposa Monarca"
            difference=Float(pointsUser-32000)
            nextLevel="Matusalén"
        }else {
            total=128000
            level="Matusalén"
            difference=Float(pointsUser)
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    
    */

}
