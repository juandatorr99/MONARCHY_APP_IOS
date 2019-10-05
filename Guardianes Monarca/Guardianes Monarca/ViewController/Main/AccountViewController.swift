//
//  AccountViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 9/25/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit
import FirebaseAuth

class AccountViewController: UIViewController {

    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelLastName: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    var account:Int=0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        if (Auth.auth().currentUser==nil){
            logOutButton.isHidden=true
            logInButton.isHidden=false
        }else{
            logOutButton.isHidden=false
            logInButton.isHidden=true
        }
    }
    @IBAction func buttonLogoutPressed(_ sender: Any) {
        
        
        do{
            try Auth.auth().signOut()
//            self.performSegue(withIdentifier: "Login", sender: self)
            logOutButton.isHidden=true
            logInButton.isHidden=false
        }
        catch{
            createAlert(view_controller: self, title: "Error", message: "Couldnt log out")
            print("Couldnt log out")
            
        }
        
        
        
    }
    
    func getData (){
        let user = Auth.auth().currentUser
        if let user = user {
          // The user's ID, unique to the Firebase project.
          // Do NOT use this value to authenticate with your backend server,
          // if you have one. Use getTokenWithCompletion:completion: instead.
          let uid = user.uid
        
          
          
          // ...
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
