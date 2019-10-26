//
//  SeedsViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 10/17/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet weak var buttonSeeds: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        buttonSeeds.layer.cornerRadius = 10
        buttonSeeds.layer.masksToBounds=true
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

