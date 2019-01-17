//
//  PreferenceViewController.swift
//  HealthyEating
//
//  Created by Bhavna Sud on 12/19/18.
//  Copyright © 2018 Bhavna Sud. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

enum KeychainError: Error {
    case unhandledError(status: OSStatus)
}

class PreferenceViewController: UIViewController {
    
    var gluten_free_box: CheckBox = CheckBox()
    var vegan_box: CheckBox = CheckBox()
    var scd_box: CheckBox = CheckBox()
    var nuts_box: CheckBox = CheckBox()
    var lactose_box: CheckBox = CheckBox()
    let board = UIStoryboard(name: "Main", bundle: nil)
    
    @IBAction func button_clicked(_ sender: Any) {
        print("gluten_free", UserDefaults.standard.bool(forKey: "gluten_free"))
        print("vegan", UserDefaults.standard.bool(forKey: "vegan"))
        print("scd", UserDefaults.standard.bool(forKey: "scd"))
        print("nut_free", UserDefaults.standard.bool(forKey: "nut_free"))
        print("lactose_free", UserDefaults.standard.bool(forKey: "lactose_free"))
        print(FBSDKAccessToken.current()?.tokenString)
    }
    
    
    @IBAction func gluten_free_clicked(_ sender: Any) {
        print("gluten_free_clicked")
        if (gluten_free_box.isChecked) {
            UserDefaults.standard.set(false, forKey: "gluten_free")
            print("set to true")
        }
        else {
            UserDefaults.standard.set(true, forKey: "gluten_free")
        }
    }
    
    @IBAction func vegan_clicked(_ sender: Any) {
        print("vegan_clicked")
        if (vegan_box.isChecked) {
            UserDefaults.standard.set(false, forKey: "vegan")
        }
        else {
            UserDefaults.standard.set(true, forKey: "vegan")
        }
    }
    
    @IBAction func scd_clicked(_ sender: Any) {
        print("scd_clicked")
        if (scd_box.isChecked) {
            UserDefaults.standard.set(false, forKey: "scd")
        }
        else {
            UserDefaults.standard.set(true, forKey: "scd")
        }
    }
    @IBAction func nut_free_clicked(_ sender: Any) {
        print("nut_free_clicked")
        if (nuts_box.isChecked) {
            UserDefaults.standard.set(false, forKey: "nut_free")
        }
        else {
            UserDefaults.standard.set(true, forKey: "nut_free")
        }
    }
    
    @IBAction func lactose_free_clicked(_ sender: Any) {
        print("lactose_free clicked!")
        if (lactose_box.isChecked) {
            UserDefaults.standard.set(false, forKey: "lactose_free")
        }
        else {
            UserDefaults.standard.set(true, forKey: "lactose_free")
        }
    }

    func postAction() {
        let Url = String(format: "https://healthyeatingapp.com/api/update")
        guard let serviceUrl = URL(string: Url) else { return }
        let parameterDictionary = ["gluten_free" : UserDefaults.standard.bool(forKey: "gluten_free"),
                                   "vegan" : UserDefaults.standard.bool(forKey: "vegan"),
                                   "scd": UserDefaults.standard.bool(forKey: "scd"),
                                   "nuts": UserDefaults.standard.bool(forKey: "nut_free"),
                                   "lactose": UserDefaults.standard.bool(forKey: "lactose_free"),
                                   "token": FBSDKAccessToken.current()?.tokenString] as [String : Any]
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                }catch {
                    print(error)
                }
            }
            let map_controller = self.parent?.children[0] as! MapViewController
            map_controller.callHomeAPI()
            }.resume()
        
    }
    
    override func viewDidLoad() {
        print("time to load")
        super.viewDidLoad()
        gluten_free_box = view.viewWithTag(1) as! CheckBox;
        vegan_box = view.viewWithTag(2) as! CheckBox;
        scd_box = view.viewWithTag(3) as! CheckBox;
        nuts_box = view.viewWithTag(4) as! CheckBox;
        lactose_box = view.viewWithTag(5) as! CheckBox;
        
        print("is it gluten free?", UserDefaults.standard.bool(forKey: "gluten_free"))
        if(UserDefaults.standard.bool(forKey: "gluten_free")) {
            gluten_free_box.isChecked = true
        }
        else {
            gluten_free_box.isChecked = false
        }
        if(UserDefaults.standard.bool(forKey: "vegan")) {
            vegan_box.isChecked = true
        }
        else {
            vegan_box.isChecked = false
        }
        if(UserDefaults.standard.bool(forKey: "scd")) {
            scd_box.isChecked = true
        }
        else {
            scd_box.isChecked = false
        }
        if(UserDefaults.standard.bool(forKey: "nut_free")) {
            nuts_box.isChecked = true
        }
        else {
            nuts_box.isChecked = false
        }
        if(UserDefaults.standard.bool(forKey: "lactose_free")) {
            lactose_box.isChecked = true
        }
        else {
            lactose_box.isChecked = false
        }
        print("finished loading")
        // Do any additional setup after loading the view.
    }
        
    @IBAction func logout_tapped(_ sender: Any) {
        postAction()
        //let fbLoginManager:FBSDKLoginManager = FBSDKLoginManager()
        ViewController.shared.fbLoginManager.logOut()
        let controller = board.instantiateViewController(withIdentifier: "ViewController")
        self.present(controller, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("called")
        self.postAction()
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

