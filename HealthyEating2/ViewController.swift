//
//  ViewController.swift
//  HealthyEating2
//
//  Created by Bhavna Sud on 12/31/18.
//  Copyright © 2018 Bhavna Sud. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "ic_check_box")! as UIImage
    let uncheckedImage = UIImage(named: "ic_check_box_outline_blank")! as UIImage
    var property: String = ""
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if(FBSDKAccessToken.current() != nil) {
            perform(#selector(showTabView), with: nil, afterDelay: 0)
            
        } else {
            UserDefaults.standard.set(false, forKey: "gluten_free")
            UserDefaults.standard.set(false, forKey: "vegan")
            UserDefaults.standard.set(false, forKey: "scd")
            UserDefaults.standard.set(false, forKey: "nut_free")
            UserDefaults.standard.set(false, forKey: "lactose_free")
        }
        
    }
    
    @objc func showTabView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TabController")
        //let mapViewController = controller.children[0].children[0] as! MapViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func login_tapped(_ sender: Any) {
        let fbLoginManager:FBSDKLoginManager = FBSDKLoginManager()
        print("hello?")
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self){(result, error) in
            if(error == nil) {
                print("here!!")
               let fbLoginResult: FBSDKLoginManagerLoginResult = result!
                if fbLoginResult.grantedPermissions != nil {
                    if(fbLoginResult.grantedPermissions.contains("email")) {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let tab_controller = storyboard.instantiateViewController(withIdentifier: "TabController")
                        self.getFBUserData(tabController: tab_controller)
                        self.present(tab_controller, animated: true, completion: nil)
                        
                   }
               }
            }
            print("error:", error)
        
        }
    }
    
    func postAction(email: String, id: String) {
        print("attempting to login")
        let Url = String(format: "https://healthyeatingapp.com/api/login")
        guard let serviceUrl = URL(string: Url) else { return }
        let parameterDictionary = ["email" : email, "id" : id, "token": FBSDKAccessToken.current().tokenString]
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            print("returning")
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
            }.resume()
    }

    
    func getFBUserData(tabController: UIViewController) {
        print("getting fb user data")
        if((FBSDKAccessToken.current()) != nil) {
            print("token", FBSDKAccessToken.current())
            print("expiration_date", FBSDKAccessToken.current().expirationDate)
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, picture.type(large), email"]).start(completionHandler:{(connection, result, error) -> Void in
                if (error == nil) {
                    print("error is nil")
                    let faceDic = result as! [String:AnyObject]
                    print(faceDic)
                    let email = faceDic["email"] as! String
                    print(email)
                    let id = faceDic["id"] as! String
                    print(id)
                    //call api to add them to the database
                    self.postAction(email: email, id: id)
                    //set the user defaults to what it says in the database
                    //let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let map_controller = tabController.children[0] as! MapViewController
                    //set the preferences in the app to the preferences recieved from the database
                    map_controller.callPreferencesAPI()
                    //map_controller.callHomeAPI()
                }
            })
        }
    }
    

}

