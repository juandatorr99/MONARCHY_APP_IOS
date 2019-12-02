//
//  RewardsViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 11/22/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class RewardsViewController: UIViewController {
var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var info:[String : AnyObject]?=[:]
    var infoPoints:[[String : AnyObject]]=[[:]]
    var points:Int=0;
    @IBOutlet weak var tableRewards: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        getAllRewards()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        
    }
    
    
    func getUserInfo() {
        
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
                        self.info = dataDescription! as [String : AnyObject]
                        if self.info!["puntos"]==nil {
                            self.points=0
                        }else{
                            self.points=self.info!["puntos"] as! Int
                        }
                            }
                        }
                        self.activityIndicator.stopAnimating()
                    } else {
                        print("Document does not exist")
                        self.activityIndicator.stopAnimating()
                        
                    }
                
               
            }
        func getReadableDate(timeStamp: TimeInterval) -> String? {
            let date = Date(timeIntervalSince1970: timeStamp)
            let dateFormatter = DateFormatter()
            
                dateFormatter.dateFormat = "MMM d, yyyy, h:mm "
                return dateFormatter.string(from: date)
            }
        
        
        
        
        
    
    
    func getAllRewards(){
            let db = Firestore.firestore()
            let dic = Timestamp(date: Date())
            
            db.collection("recompensas").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    self.activityIndicator.stopAnimating()
                } else {
                    print("SISISISIS")
                    for document in querySnapshot!.documents {
                        
                        print("\(document.documentID) => \(document.data())")
                        let dataDescription = document.data()
                        print(dataDescription)
                        self.infoPoints.append(dataDescription as [String : AnyObject])
                        
                    }
    //                for infoa in self.info {
    //                    print(infoa)
    //                    self.eventNameArr.append(infoa["nombre"] as! String)
    //                }
                    self.tableRewards.reloadData()
                    self.activityIndicator.stopAnimating()
                    
                    //print (Date().timeIntervalSince1970)
                    //print(self.info.count)
                   
            }
            }
            
        }
}

extension RewardsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return infoPoints.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rewardsCell", for: indexPath ) as! RewardsTableViewCell
        
        
        let eventsInfo = infoPoints[indexPath.row]
        print(eventsInfo)
        if eventsInfo["titulo"] != nil{
            cell.titulo.text = eventsInfo["titulo"] as! String
                
                         let postTimestamp = eventsInfo["vigencia"] as? Timestamp
            print(getReadableDate(timeStamp: TimeInterval(postTimestamp!.seconds))!)
            let date = Date(timeIntervalSince1970: TimeInterval(postTimestamp!.seconds))
                         print(eventsInfo)
            cell.tienda.text = "Tienda: \( eventsInfo["empresa"] as! String )"
            cell.vigencia.text = "Vigencia: \(getReadableDate(timeStamp: TimeInterval(postTimestamp!.seconds))!) "
            cell.descripcion.text =  "\(eventsInfo["descripcion"] as! String )"
        return cell
        }else{
            return cell
        }
        
        
           
          
    //
          
    }
   
}
