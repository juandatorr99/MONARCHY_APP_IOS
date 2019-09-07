//
//  ViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 9/1/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show the selected screen
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Instantiate the selected screen view controller
        let nextViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        
        // Every storyboard must have a NavigationController named "MainNavigation"
        let navigationController = storyboard.instantiateViewController(withIdentifier: "MainNavigation") as! UINavigationController
        navigationController.setViewControllers([nextViewController], animated: true)
        
        // Present the navigaton controller and within it, the view controller
        self.present(navigationController, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    

}

