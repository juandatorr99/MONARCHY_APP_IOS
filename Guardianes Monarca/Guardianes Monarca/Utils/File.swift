//
//  File.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 10/4/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
class Model :NSObject{
    static let sharedInstance = Model()
    
    func addPoints( pointsToAdd:Int)   {
        var actualPoints:Int = 0
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
                    let info = dataDescription! as [String : AnyObject]

                    actualPoints = info["puntos"] as? Int ?? 0
                    print(actualPoints)
                    actualPoints=actualPoints+pointsToAdd
                    print(actualPoints)
                    
                } else {
                    print("Document does not exist")
                    
                }
            }
            
            
          DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
              actualUser.updateData([
                      "puntos": actualPoints
                  ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        
                        print("Document successfully updated")
                    }
              }
          })
            
        }
        
    }
    
    
    func getUserInfo()->[String : AnyObject]{
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

                    
                    
                } else {
                    print("Document does not exist")
                    
                }
            }
            return info!
    }
    
    return info!

    
}
}
