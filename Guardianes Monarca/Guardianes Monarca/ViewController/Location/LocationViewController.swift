//
//  LocationViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 10/3/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var latitudeLocation:Double = 0.0
    var longitudeLocation:Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: {
                self.locationManager.stopUpdatingLocation()
            })
        
    }
    
    }
    
    
    
    @IBAction func registerLocationButterfly(_ sender: Any) {
        
        
        
            
            if(!(latitudeLocation==0.0)){
                var ref: DocumentReference? = nil
                let db = Firestore.firestore()
               ref = db.collection("localizacion").addDocument(data:[
                 "latitud":latitudeLocation,
                 "longitud":longitudeLocation,
                 "fecha":Timestamp(date: Date())
                    
                    
                ]){ err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        self.createAlert(view_controller: self, title: "Error", message: "Error Ubicacion")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        if Auth.auth().currentUser==nil {
                            self.createAlert(view_controller: self, title: "Registro Exitoso", message: "Haz registrado una Mariposa Monarca\nGracias por tu apoyo a su concervacion.")
                        }else{
                        self.createAlert(view_controller: self, title: "Registro Exitoso", message: "Haz registrado una Mariposa Monarca\nGracias por tu apoyo a su concervacion.\nHaz ganado 50 puntos!")
                        }
                        Model.sharedInstance.addPoints(pointsToAdd: 50)
                            
                        
                        }
                        
                        
                            
                        }
                       
                    }
                
            }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        latitudeLocation=locValue.latitude
        longitudeLocation = locValue.longitude
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status==CLAuthorizationStatus.denied){
            showDisableLocationPopUp()
        }
    }
    
    
    func showDisableLocationPopUp(){
        createAlert(view_controller: self, title: "El acceso a la ubicacion fue deshabilitada", message: "Necesitamos tu ubicacion para registrar la mariposa")
        let alertController = UIAlertController(title: "El acceso a la ubicacion fue deshabilitada", message: "Necesitamos tu ubicacion para registrar la mariposa", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: "Abrir Ajustes", style: .default){ (action) in
            if let url = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
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
