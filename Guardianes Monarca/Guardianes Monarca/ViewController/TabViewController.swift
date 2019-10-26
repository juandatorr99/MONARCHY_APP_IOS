//
//  TabViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 10/16/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    @IBInspectable var defaultIndex: Int = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
        print("empexo")
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
