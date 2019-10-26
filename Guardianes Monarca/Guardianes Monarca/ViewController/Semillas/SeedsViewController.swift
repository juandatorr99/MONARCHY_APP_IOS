//
//  SeedsViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 10/25/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SeedsViewController: UIViewController {
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
       
    @IBOutlet weak var tableViewSeeds: UITableView!
    var query:QuerySnapshot?
       var info: [[String:Any]] = []
    override func viewDidAppear(_ animated: Bool) {
    //        getAllEvents()
            
            

            if CheckInternet.Connection(){
                
            }else{
                activityIndicator.stopAnimating()
                createAlert(view_controller: self, title: "Sin Conexion", message: "No hay conexion a Internet")
            }
        }
        override func viewDidLoad() {
            super.viewDidLoad()
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.gray
             
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            getAllEvents()
            // Do any additional setup after loading the view.
        }
    func getAllEvents(){
        let db = Firestore.firestore()
       
        
        db.collection("semillas").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.activityIndicator.stopAnimating()
            } else {
                
                for document in querySnapshot!.documents {
                    
                    print("\(document.documentID) => \(document.data())")
                    let dataDescription = document.data()
                    print(dataDescription)
                    self.info.append(dataDescription as [String : AnyObject])
                    
                }
                for infoa in self.info {
                    print(infoa)
                }
                self.tableViewSeeds.reloadData()
                self.activityIndicator.stopAnimating()
                //print (Date().timeIntervalSince1970)
                //print(self.info.count)
        }
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
extension SeedsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "seedCell", for: indexPath ) as! SeedsTableViewCell
                      let eventsInfo = info[indexPath.row]
                      
              //        print(date)
        cell.nameLabel.text = "\(eventsInfo["nombre"] ?? "Nombre")"
                    cell.descriptionLabel.text = "\(eventsInfo["descripcion"] ?? "descripcion")"
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
                      
              //
                      return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
//        if UIApplication.shared.canOpenURL(url!) {
//            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//        }
//        print("selected\(eventsInfo["link"]!)")
    }
}
