//
//  MapViewController.swift
//  HealthyEating2
//
//  Created by Bhavna Sud on 12/31/18.
//  Copyright © 2018 Bhavna Sud. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

struct Preferences: Decodable {
    let status: String
    let gluten_free: Bool
    let vegan: Bool
    let scd: Bool
    let nuts: Bool
    let lactose: Bool
}

struct Restauraunts: Decodable {
    let status: String
    let restauraunt_list: [Restauraunt]
}
struct Restauraunt: Decodable {
    let name: String
    let latitude: float_t
    let longitude: float_t
    let website: String
    let address: String
    let menu_items: [Item]
}

struct Item: Decodable {
    let item_name: String
    let gluten_free: Bool
    let vegan: Bool
    let scd: Bool
    let nuts: Bool
    let lactose: Bool
}

class MapViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded")
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        //let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        //let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        //view = mapView
        
        // Creates a marker in the center of the map.
        //let marker = GMSMarker()
        //marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        //marker.title = "Sydney"
        //marker.snippet = "Australia"
        //marker.map = mapView
        button.setTitle(FBSDKAccessToken.current()?.userID, for: .normal)
        // Do any additional setup after loading the view.
    }
    

    @IBAction func logout_tapped(_ sender: Any) {
        let fbLoginManager:FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ViewController")
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func test_button(_ sender: Any) {
        let result = callPreferencesAPI()
        //print("hi")
        //print(result)
        
        callHomeAPI()
    }
    
    func callPreferencesAPI() -> Preferences {
        var preferences = Preferences(status: "not ok",gluten_free: false, vegan: false, scd: false, nuts: false, lactose: false)
        guard let url = URL(string: "http://apptesting.getsandbox.com/preferences") else {return preferences}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                //here dataResponse received from a network request
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                //print("response")
                //print(jsonResponse)
                //how to change preferences variable inside this method??
                //it seems to be making a new variable preferences instead of modifying the old one
                preferences = try JSONDecoder().decode(Preferences.self, from: dataResponse)
                UserDefaults.standard.set(preferences.gluten_free, forKey: "gluten_free")
                UserDefaults.standard.set(preferences.vegan, forKey: "vegan")
                UserDefaults.standard.set(preferences.nuts, forKey: "nut_free")
                UserDefaults.standard.set(preferences.lactose, forKey: "lactose_free")
                UserDefaults.standard.set(preferences.scd, forKey: "scd")
                //how to return this preferences??
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        //print(preferences)
        task.resume()
        return preferences
    }
    
    func callHomeAPI() {
        guard let url = URL(string: "http://apptesting.getsandbox.com/home") else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                //here dataResponse received from a network request
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                //parsing data --> converting it to Restauraunts object
                let home_data = try JSONDecoder().decode(Restauraunts.self, from: dataResponse)
                //print(home_data)
                
                
                for restauraunt in home_data.restauraunt_list {
                    print(restauraunt.name)
                    print(restauraunt.address + "\n")
                }
                
                let restauraunt_three = home_data.restauraunt_list[2]
                print(restauraunt_three.name)
                print(restauraunt_three.address)
                print(restauraunt_three.website)
                
                var gluten_free_items: [String] = []
                var vegan_items: [String] = []
                var scd_items: [String] = []
                var nut_free_items: [String] = []
                var lactose_free_items: [String] = []
                
                for item in restauraunt_three.menu_items {
                    if item.gluten_free {gluten_free_items.append(item.item_name)}
                }
                for item in restauraunt_three.menu_items {
                    if item.vegan {vegan_items.append(item.item_name)}
                }
                for item in restauraunt_three.menu_items {
                    if item.scd {scd_items.append(item.item_name)}
                }
                for item in restauraunt_three.menu_items {
                    if item.nuts {nut_free_items.append(item.item_name)}
                }
                for item in restauraunt_three.menu_items {
                    if item.lactose {lactose_free_items.append(item.item_name)}
                }
                if(gluten_free_items.count != 0) {
                    print("\nGluten Free")
                    print(gluten_free_items)
                }
                if(vegan_items.count != 0) {
                    print("\nVegan")
                    print(vegan_items)
                }
                if(scd_items.count != 0) {
                    print("\nSCD")
                    print(scd_items)
                }
                if(nut_free_items.count != 0) {
                    print("\nNo Nuts")
                    print(nut_free_items)
                }
                if(lactose_free_items.count != 0) {
                    print("\nLactose Free")
                    print(lactose_free_items)
                }
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
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
