//
//  SettingsViewController.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 10/23/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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


extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath ) as! SettingsTableViewCell
        switch indexPath.row {
        case 0:
            cell.label.text = "Editar Perfil"
            return cell

        case 1:
        cell.label.text = "Quienes Somos"
        return cell
            
        case 2:
            cell.label.text = "Codigo de Compañia"
            return cell

        case 3:
            cell.label.text = "Puntos de Venta"
            return cell

        case 4:
           cell.label.text = "Términos y Condiciones"
           return cell

        case 5:
           cell.label.text = "Avisos de Privacidad"
           return cell



        default:
            print("Error")
            return cell
        }
                    
              
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
            case 0:
                if Auth.auth().currentUser==nil {
                    createAlert(view_controller: self, title: "Aviso", message: "Debes iniciar sesión para poder editar tu perfil")
                    tableView.deselectRow(at: indexPath, animated: true)
                }else{
                    performSegue(withIdentifier: "editProfile", sender: self)
                    tableView.deselectRow(at: indexPath, animated: true)
            }
                
            break
            
            case 2:
                if Auth.auth().currentUser==nil {
                    createAlert(view_controller: self, title: "Aviso", message: "Debes iniciar sesión para poder registrar el código de tu compañía")
                    tableView.deselectRow(at: indexPath, animated: true)
                }else{
                    performSegue(withIdentifier: "registerCompanyCode", sender: self)
                    tableView.deselectRow(at: indexPath, animated: true)
            }
                
            break
            case 4:
                
                performSegue(withIdentifier: "termsAndConditions", sender: self)
                tableView.deselectRow(at: indexPath, animated: true)
            
                
            break
            default:
                return
        }
    }
    
}

