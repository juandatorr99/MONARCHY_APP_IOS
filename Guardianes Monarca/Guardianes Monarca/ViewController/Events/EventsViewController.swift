//
//  EventsViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 10/14/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SafariServices


class EventsViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
   var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var tableEvents: UITableView!
    var query:QuerySnapshot?
    var info: [[String:Any]] = []
    var searchEvent: [[String:Any]] = []
//    var eventNameArr: [[String:Any]] = []
    var search=false
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
//        getAllEvents()
//        configureTapGesture()
        

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
        let dic = Timestamp(date: Date())
        
        db.collection("eventos").whereField("fecha",isGreaterThanOrEqualTo:dic ).getDocuments() { (querySnapshot, err) in
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
//                for infoa in self.info {
//                    print(infoa)
//                    self.eventNameArr.append(infoa["nombre"] as! String)
//                }
                self.tableEvents.reloadData()
                self.activityIndicator.stopAnimating()
                //print (Date().timeIntervalSince1970)
                //print(self.info.count)
               
        }
        }
        
    }
    private func configureTapGesture(){
         let tapGesture=UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleTap))
         view.addGestureRecognizer(tapGesture)
     }
     
    
     
     @objc func handleTap(){
         view.endEditing(true)
     }
     
    func getReadableDate(timeStamp: TimeInterval) -> String? {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        
            dateFormatter.dateFormat = "MMM d, yyyy, h:mm "
            return dateFormatter.string(from: date)
        }
    
    
    
    }


extension EventsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if search{
            return searchEvent.count
        }else{
            return info.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath ) as! EventsCollectionViewCell
        
        if search{
            let eventsInfo = searchEvent[indexPath.row]
            cell.labelNombre.text = eventsInfo["nombre"] as! String
            
                     let postTimestamp = eventsInfo["fecha"] as! Timestamp
                     print(getReadableDate(timeStamp: TimeInterval(postTimestamp.seconds))!)
                     let date = Date(timeIntervalSince1970: TimeInterval(postTimestamp.seconds))
                     print(eventsInfo)
            cell.labelLugar.text = "Lugar: \(eventsInfo["lugar"] ?? "Lugar")"
            cell.labelFecha.text = "Fecha: \(getReadableDate(timeStamp: TimeInterval(postTimestamp.seconds))!) "
            cell.labelDescripcion.text =  "\(eventsInfo["descripcion"] ?? "Descripcion")"
        }else{
            let eventsInfo = info[indexPath.row]
                  let postTimestamp = eventsInfo["fecha"] as! Timestamp
                  print(getReadableDate(timeStamp: TimeInterval(postTimestamp.seconds))!)
                  let date = Date(timeIntervalSince1970: TimeInterval(postTimestamp.seconds))
                  print(eventsInfo)
            //        print(date)
                  cell.labelNombre.text = "\(eventsInfo["nombre"] ?? "Nombre")"
                  cell.labelLugar.text = "Lugar: \(eventsInfo["lugar"] ?? "Lugar")"
                  cell.labelFecha.text = "Fecha: \(getReadableDate(timeStamp: TimeInterval(postTimestamp.seconds))!) "
                  cell.labelDescripcion.text =  "\(eventsInfo["descripcion"] ?? "Descripcion")"
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        }
          
          
    //
          return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var eventsInfo:[String:Any]
        if search{
             eventsInfo = searchEvent[indexPath.row]
        }else{
             eventsInfo = info[indexPath.row]
        }
        
        
        let url = URL(string: "https://\(eventsInfo["link"]!)")!
        print(url)
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
        
        
//        if UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
        print("selected\(eventsInfo["link"]!)")
    }
}
extension EventsViewController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchEvent = info.filter({($0["nombre"] as! String ).lowercased().prefix(searchText.count) == searchText.lowercased()})
        search=true
        tableEvents.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search = false
        searchBar.text=""
        handleTap()
        tableEvents.reloadData()
    }
}

//extension EventsViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 40, height: 40) // Return any non-zero size here
//    }
//}
