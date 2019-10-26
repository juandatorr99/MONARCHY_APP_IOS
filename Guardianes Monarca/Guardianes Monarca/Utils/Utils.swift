//
//  Utils.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 9/27/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import Foundation
import UIKit
import os.log
import SystemConfiguration
import MBProgressHUD
import FirebaseAuth
import FirebaseFirestore

class Utils {
    
    
        
    
    
    
    
    let isDebug: Bool = {
        var isDebug = false
        // function with a side effect and Bool return value that we can pass into assert()
        func set(debug: Bool) -> Bool {
            isDebug = debug
            return isDebug
        }
        // assert:
        // "Condition is only evaluated in playgrounds and -Onone builds."
        // so isDebug is never changed to true in Release builds
        assert(set(debug: true))
        return isDebug
    }()

    /// From: https://gist.github.com/M-Medhat/a793c3163b4fbbe46976
    /// This function takes three parameters
    /// text: a string that we search in
    /// pattern: a reqular expression pattern to use in the search
    /// withTemplate: the string that we use instead of the occurrances we find in text
    ///
    /// The method returns (text) with occurrance found using (pattern) replaced with (withTemplate)
    static func regexReplace(text: String, pattern: String, withTemplate: String) throws -> String {
        // Create an object of type NSRegularExpression. We'll call this objects methods to perform
        // RegEx operations, in this case, replacement. The object is initialized with three parameters
        // the (pattern) used in the search, (options) in this case we're using CaseInsensitive search
        // and (error) a pointer to an NSError object to assign errors to in case any errors happen.
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        // We're calling stringByReplacingMatchesInString on the regex object. The method accepts four paramteres:
        // the (text) to search in, (options) in this case, none, the (range) to search in, in the string and here we're searching
        // the whole string and finally (withTemplate) contains the value to be used.
        // In case we succeed, assign the updated text to _text variable.
        return regex.stringByReplacingMatches(in: text, options: .reportProgress, range: NSMakeRange(0, text.count), withTemplate: withTemplate)
    }
    
    // Shows an alert with an OK button
    static func showAlert(title: String, message: String) {
        showAlert(title: title, message: message) {}
    }
    
    // Shows an alert with an OK button
    static func showAlert(title: String, message: String, completion: @escaping () -> Void) {
        if let viewController = UIApplication.getTopMostViewController() {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: {(_) in completion()}))
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    // Shows an alert with an OK button
    static func showAlertOkCancel(title: String, message: String, onOk: (()->Void)?, onCancel: (()->Void)?) {
        if let viewController = UIApplication.getTopMostViewController() {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: {(_) in onOk?()}))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {(_) in onCancel?()}))
            viewController.present(alert, animated: true, completion: nil)
        }
    }

    // Creates a SHA256 hash of the given string.
    // Remember to include a BridgingHeader.h and configure it in the project settings for this function to work
    // (Project / Target / BuildSettings / All / Swift Compiler - General / Objective-C Bridging Header -> {relative path to root of project)/BrdingingHeader.h
    // Only this line needs to be in BridgingHeader.h: #import <CommonCrypto/CommonHMAC.h>
    
    // Resize an UIImage
    // From https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize

        // No need to resize
        if widthRatio > 1 && heightRatio > 1 { return image }

        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    // Makes an image square and centers it.
    static func squareImage(_ image: UIImage) -> UIImage? {
        let size = image.size

        if size.width == size.height {return image}

        let d = size.width > size.height ? size.height : size.width
        let rect = CGRect(x: (size.width - d)/2.0, y: (size.height - d)/2.0, width: d, height: d)

        if let imageref = image.cgImage?.cropping(to: rect) {
            return UIImage(cgImage: imageref)
        }
        return nil
    }
    
    enum NavigationError: Error {
        case invalidNavigationController
    }
    
    static func unwindOrReplaceViewController(unwindSegue: String, storyboard: UIStoryboard, nextViewController: String, callingViewController: UIViewController, pop: Bool) throws {
        guard let navigationController = callingViewController.navigationController else {
            throw NavigationError.invalidNavigationController
        }
        
        var found = false
        for vc in navigationController.viewControllers {
            // Make sure that in the storyboard the restoration id is the same as the storyobard id
            if vc.restorationIdentifier != nil && vc.restorationIdentifier == nextViewController {
                os_log("Restoration Identifier: %@", log: .default, type: .info, vc.restorationIdentifier ?? "nil")
                found = true
                break
            }
        }
        
        if found {
            os_log("Unwinding to existing view controller", log: .default, type: .info)
            callingViewController.performSegue(withIdentifier: unwindSegue, sender: callingViewController)
        }
        else {
            os_log("New instance", log: .default, type: .info)
            // Instantiate the selected screen view controller
            let viewController = storyboard.instantiateViewController(withIdentifier: nextViewController)
            
            // Every storyboard must have a NavigationController named "MainNavigation"
            if pop {
                navigationController.popViewController(animated: false)
            }
            navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    static func AttributedTextFile(_ fileName: String) -> NSAttributedString {
        do {
            return try NSAttributedString(url: Bundle.main.url(forResource: fileName, withExtension: ".rtf")!, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
        }
        catch {
            os_log("Error while reading attributed file: %@", log: .default, type: .error, error.localizedDescription)
            return NSAttributedString(string: "")
        }
    }
}
extension UIViewController {
    
    func startAuthController(){
        let c = getStoryboard().instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(c, animated: true)
    }
    
    func createAlert(view_controller: UIViewController, title: String, message: String) {
        let alertC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alertC.addAction(OKAction)
        view_controller.present(alertC, animated: true, completion: nil)
    }
   
    
    
    /// Show a UIAlertController with the specified message
    func showAlert(withMessage message: String) {
        
        let alert = UIAlertController(
            title: "Oops...",
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        
        let action = UIAlertAction(
            title: "Ok",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func getLoader(withMessage msg: String = "Cargando ...") -> MBProgressHUD {
        let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
        loader.mode = MBProgressHUDMode.indeterminate
        loader.label.text = msg
        return loader;
    }
    
    func makeNavigationBarInvisible() {
        let navBar = self.navigationController?.navigationBar
        if navBar != nil {
            navBar!.setBackgroundImage(UIImage(), for: .default)
            navBar!.shadowImage = UIImage()
            navBar!.isTranslucent = true
        }
    }
    
    func makeNavigationBarVisible() {
        let navBar = self.navigationController?.navigationBar
        if navBar != nil {
            navBar!.setBackgroundImage(nil, for: .default)
            navBar!.shadowImage = UIImage()
            navBar!.isTranslucent = true
        }
    }
    
    func imageInNavBar() {
        let image = UIImage(named: "logonav.jpg")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }
    
    /// Instance of Main Storyboard
    func getStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    
    func statusOrder(status: String) -> String {
        
        var statusSpanish = ""
        if status == "pending" {
            statusSpanish = "Pendiente"
        }
        
        if status == "accepted" {
            statusSpanish = "Aceptado"
        }
        
        if status == "rejected" {
            statusSpanish = "Rechazado"
        }
        
        if status == "delivered" {
            statusSpanish = "Entregado"
        }
        return statusSpanish
    }
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
    
    func handleNSError(_ error: NSError) {
        NSLog("\(error.code): \(error.localizedDescription)")
        self.showAlert(withMessage: error.localizedDescription)
    }
    
    func handleError(_ error: Error) {
        NSLog(error.localizedDescription)
        self.showAlert(withMessage: error.localizedDescription)
    }
    
    func handleErrorDescription(_ error: NSError) {
        NSLog(error.description)
        self.showAlert(withMessage: error.localizedDescription)
    }
    
    func showToast(message: String) {
        
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        
        let toastLabel = UILabel(frame: CGRect(x: w / 2, y: h, width: 220, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Helvetica", size: 12.0)
        toastLabel.text = message
        toastLabel.center = CGPoint(x: w / 2, y: h - 130)
        toastLabel.alpha = 0.0
        toastLabel.numberOfLines = 0
        toastLabel.layer.cornerRadius = 35 / 2;
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 0.6, animations: {
            toastLabel.alpha = 1.0
        }, completion: { (isCompleted) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.6) {
                UIView.animate(withDuration: 0.6, animations: {
                    toastLabel.alpha = 0.0
                }, completion: { (isCompleted) in
                    toastLabel.removeFromSuperview()
                })
            }
        })
    }
}

extension UIApplication {
    class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
}
