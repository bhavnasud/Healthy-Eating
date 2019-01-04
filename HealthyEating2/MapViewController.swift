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
import GoogleMaps
import GooglePlaces

struct Preferences: Decodable {
    let status: String
    let gluten_free: Bool
    let vegan: Bool
    let scd: Bool
    let nuts: Bool
    let lactose: Bool
}

struct Restaurants: Decodable {
    let status: String
    let restaurant_list: [Restaurant]
}
struct Restaurant: Decodable {
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




class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    private let locationManager = CLLocationManager()
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    var tappedMarker : GMSMarker?
    var customInfoWindow : CustomInfoWindow?
    var home_data: Restaurants?
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //5
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        self.tappedMarker = GMSMarker()
        self.customInfoWindow = CustomInfoWindow().loadView()
        self.customInfoWindow?.body_label.numberOfLines = 0
        self.callHomeAPI()
        // Do any additional setup after loading the view.
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("here is title", marker.title)
        self.customInfoWindow = CustomInfoWindow().loadView()
        self.customInfoWindow?.body_label.numberOfLines = 12
        self.customInfoWindow?.title_label.text = marker.title
        var string_to_print = ""
        for restaurant in (home_data?.restaurant_list)! {
            if restaurant.name == marker.title {
                print("testing,", restaurant.name)
                var gluten_free_items: [String] = []
                var vegan_items: [String] = []
                var scd_items: [String] = []
                var nut_free_items: [String] = []
                var lactose_free_items: [String] = []
                
                for item in (restaurant.menu_items) {
                    if item.gluten_free {gluten_free_items.append(item.item_name)}
                    if item.vegan {vegan_items.append(item.item_name)}
                    if item.scd {scd_items.append(item.item_name)}
                    if item.nuts {nut_free_items.append(item.item_name)}
                    if item.lactose {lactose_free_items.append(item.item_name)}
                }
                if(gluten_free_items.count != 0 && UserDefaults.standard.bool(forKey: "gluten_free")) {
                    string_to_print.append("Gluten Free\n")
                    for item in gluten_free_items {
                        string_to_print.append(item+"\n")
                    }
                }
                if(vegan_items.count != 0  && UserDefaults.standard.bool(forKey: "vegan")) {
                    string_to_print.append("Vegan\n")
                    for item in vegan_items {
                        string_to_print.append(item+"\n")
                    }
                }
                if(scd_items.count != 0 && UserDefaults.standard.bool(forKey: "scd")) {
                    string_to_print.append("SCD\n")
                    for item in scd_items {
                        string_to_print.append(item+"\n")
                    }
                }
                if(nut_free_items.count != 0 && UserDefaults.standard.bool(forKey: "nut_free")) {
                    string_to_print.append("No Nuts\n")
                    for item in nut_free_items {
                        string_to_print.append(item+"\n")
                    }
                }
                if(lactose_free_items.count != 0 && UserDefaults.standard.bool(forKey: "lactose_free")) {
                    string_to_print.append("Lactose Free\n")
                    for item in lactose_free_items {
                        string_to_print.append(item+"\n")
                    }
                }

            }
        }
        self.customInfoWindow?.body_label.text = string_to_print
        marker.map = mapView
        return false
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return self.customInfoWindow
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.callHomeAPI()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        locationManager.startUpdatingLocation()
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
        print("hi")
        print(result)
        
        callHomeAPI()
    }
    
    func callPreferencesAPI() -> Preferences {
        var preferences = Preferences(status: "not ok",gluten_free: false, vegan: false, scd: false, nuts: false, lactose: false)
        let Url = String(format: "http://apptesting.getsandbox.com/preferences")
        guard let serviceUrl = URL(string: Url) else { return preferences }
        let parameterDictionary = ["token" : FBSDKAccessToken.current()?.tokenString]
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return preferences
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print("results", response)
            }
            if let data = data {
                print("data", data)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("json!", json)
                    preferences = try JSONDecoder().decode(Preferences.self, from: data)
                    UserDefaults.standard.set(preferences.gluten_free, forKey: "gluten_free")
                    UserDefaults.standard.set(preferences.vegan, forKey: "vegan")
                    UserDefaults.standard.set(preferences.nuts, forKey: "nut_free")
                    UserDefaults.standard.set(preferences.lactose, forKey: "lactose_free")
                    UserDefaults.standard.set(preferences.scd, forKey: "scd")
                }catch {
                    print(error)
                }
            }
            }.resume()
        return preferences
    }
    
    func callHomeAPI() {
        let Url = String(format: "http://apptesting.getsandbox.com/home3")
        guard let serviceUrl = URL(string: Url) else { return }
        let parameterDictionary = ["latitude" : self.location?.coordinate.latitude,
                                   "longitude" : self.location?.coordinate.longitude,
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
                print("results", response)
            }
            if let data = data {
                print("data", data)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("json!", json)
                    self.home_data = try JSONDecoder().decode(Restaurants.self, from: data)
                    print("first name",self.home_data?.restaurant_list[0].name)
                    self.updateData()
                }catch {
                    print(error)
                }
            }
            }.resume()
        let position = CLLocationCoordinate2D(latitude: 37, longitude: -122)
        //let london = GMSMarker(position: position)
        //london.title = "London"
        //london.snippet = "Res. C\ntesting address\nhttps://google.com\nGluten Free\nsalad, apple, bread\nVegan\nsalad, apple, bread\nSCD\nsalad, apple, bread\nNo Nuts\nsalad, apple, bread"
        //london.map = mapView
        let marker = GMSMarker()
        marker.position = position
    }
    
    func updateData() {
        print("self.home_data", self.home_data)
        print("first name final",self.home_data!.restaurant_list[0].name)
        for restaurant in (self.home_data?.restaurant_list)! {
            print(restaurant.name)
            print(restaurant.address + "\n")
            let marker = GMSMarker()
            marker.title = restaurant.name
            let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(restaurant.latitude), longitude: CLLocationDegrees(restaurant.longitude))
            marker.position = position
            print(marker.position)
            marker.map = self.mapView
            print("title:", marker.title)
        }
        
        let restaurant_three = self.home_data?.restaurant_list[2]
        print(restaurant_three?.name)
        print(restaurant_three?.address)
        print(restaurant_three?.website)
        
        var gluten_free_items: [String] = []
        var vegan_items: [String] = []
        var scd_items: [String] = []
        var nut_free_items: [String] = []
        var lactose_free_items: [String] = []
        
        for item in (restaurant_three?.menu_items)! {
            if item.gluten_free {gluten_free_items.append(item.item_name)}
        }
        for item in (restaurant_three?.menu_items)! {
            if item.vegan {vegan_items.append(item.item_name)}
        }
        for item in (restaurant_three?.menu_items)! {
            if item.scd {scd_items.append(item.item_name)}
        }
        for item in (restaurant_three?.menu_items)! {
            if item.nuts {nut_free_items.append(item.item_name)}
        }
        for item in (restaurant_three?.menu_items)! {
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

// MARK: - CLLocationManagerDelegate
//1
extension MapViewController {
    // 2
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 3
        guard status == .authorizedWhenInUse else {
            return
        }
        // 4
        locationManager.startUpdatingLocation()
        
    }
    
    // 6
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.first
        
        // 7
        mapView.camera = GMSCameraPosition(target: (self.location?.coordinate)!, zoom: 15, bearing: 0, viewingAngle: 0)
        
        // 8
        locationManager.stopUpdatingLocation()
    }
}

