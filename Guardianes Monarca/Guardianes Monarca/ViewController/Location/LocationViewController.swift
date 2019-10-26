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
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        //Activity Indicator
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        
        view.addSubview(activityIndicator)
        
    
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if CLLocationManager.locationServicesEnabled(){
                    locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: {
        //                self.locationManager.stopUpdatingLocation()
        //            })
                
                }else{
                    locationManager.stopUpdatingLocation()
                }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
        print("Stopped updating")
    }
    
    @IBAction func registerLocationButterfly(_ sender: Any) {
        activityIndicator.startAnimating()
            if CheckInternet.Connection(){
                       
                   }else{
                       createAlert(view_controller: self, title: "Sin Conexion", message: "No hay conexion a Internet")
                   }
            if CLLocationManager.locationServicesEnabled(){
                locationManager.startUpdatingLocation()
            }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            print("started")
            if(!(self.latitudeLocation==0.0)){
                print("startedRegistering")
                var ref: DocumentReference? = nil
                let db = Firestore.firestore()
               ref = db.collection("localizacion").addDocument(data:[
                "latitud":self.latitudeLocation,
                "longitud":self.longitudeLocation,
                 "fecha":Timestamp(date: Date())
                    
                    
                ]){ err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        self.activityIndicator.stopAnimating()
                        self.createAlert(view_controller: self, title: "Error", message: "Error Ubicacion")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        if Auth.auth().currentUser==nil {
                            self.activityIndicator.stopAnimating()
                            self.createAlert(view_controller: self, title: "Registro Exitoso", message: "Haz registrado una Mariposa Monarca\nGracias por tu apoyo a su concervacion.")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                                            self.locationManager.stopUpdatingLocation()
                                        })
                        }else{
                            self.activityIndicator.stopAnimating()
                        self.createAlert(view_controller: self, title: "Registro Exitoso", message: "Haz registrado una Mariposa Monarca\nGracias por tu apoyo a su concervacion.\nHaz ganado 50 puntos!")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                                self.locationManager.stopUpdatingLocation()
                                print("Stopped updating")
                            })
                        }
                        Model.sharedInstance.addPoints(pointsToAdd: 50)
                            
                        
                        }
                        
                        
                            
                        }
                       
                    }
    })
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
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
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

  

}

