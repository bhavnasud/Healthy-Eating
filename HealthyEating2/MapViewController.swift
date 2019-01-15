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
    //var customInfoWindow : CustomInfoWindow?
    var home_data: Restaurants?
    var location: CLLocation?
    var home_called = false
    let board = UIStoryboard(name: "Main", bundle: nil)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //5
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        self.tappedMarker = GMSMarker()
        //self.customInfoWindow = CustomInfoWindow().loadView()
        //self.customInfoWindow?.body_label.numberOfLines = 0
        //self.callHomeAPI()
        //self.updateData()
        // Do any additional setup after loading the view.
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("here is title", marker.title)
        //self.customInfoWindow = CustomInfoWindow().loadView()
        //self.customInfoWindow?.body_label.numberOfLines = 12
        //self.customInfoWindow?.title_label.text = marker.title
        var string_to_print = ""
        var latitude: float_t?
        var longitude: float_t?
        for restaurant in (home_data?.restaurant_list)! {
            if restaurant.name == marker.title {
                print("testing,", restaurant.name)
                for item in restaurant.menu_items {
                    if (!item.gluten_free && UserDefaults.standard.bool(forKey: "gluten_free")) ||
                       (!item.vegan && UserDefaults.standard.bool(forKey: "vegan")) ||
                       (!item.scd && UserDefaults.standard.bool(forKey: "scd")) ||
                       (!item.nuts && UserDefaults.standard.bool(forKey: "nut_free")) ||
                        (!item.lactose && UserDefaults.standard.bool(forKey: "lactose_free")) {
                    }
                    else {
                        string_to_print.append(item.item_name+"\n")
                    }
                }
                latitude = restaurant.latitude
                longitude = restaurant.longitude
//                var gluten_free_items: [String] = []
//                var vegan_items: [String] = []
//                var scd_items: [String] = []
//                var nut_free_items: [String] = []
//                var lactose_free_items: [String] = []
//
//                for item in (restaurant.menu_items) {
//                    if item.gluten_free {gluten_free_items.append(item.item_name)}
//                    if item.vegan {vegan_items.append(item.item_name)}
//                    if item.scd {scd_items.append(item.item_name)}
//                    if item.nuts {nut_free_items.append(item.item_name)}
//                    if item.lactose {lactose_free_items.append(item.item_name)}
//                }
//                if(gluten_free_items.count != 0 && UserDefaults.standard.bool(forKey: "gluten_free")) {
//                    string_to_print.append("Gluten Free\n")
//                    for item in gluten_free_items {
//                        string_to_print.append(item+"\n")
//                    }
//                }
//                if(vegan_items.count != 0  && UserDefaults.standard.bool(forKey: "vegan")) {
//                    string_to_print.append("Vegan\n")
//                    for item in vegan_items {
//                        string_to_print.append(item+"\n")
//                    }
//                }
//                if(scd_items.count != 0 && UserDefaults.standard.bool(forKey: "scd")) {
//                    string_to_print.append("SCD\n")
//                    for item in scd_items {
//                        string_to_print.append(item+"\n")
//                    }
//                }
//                if(nut_free_items.count != 0 && UserDefaults.standard.bool(forKey: "nut_free")) {
//                    string_to_print.append("No Nuts\n")
//                    for item in nut_free_items {
//                        string_to_print.append(item+"\n")
//                    }
//                }
//                if(lactose_free_items.count != 0 && UserDefaults.standard.bool(forKey: "lactose_free")) {
//                    string_to_print.append("Lactose Free\n")
//                    for item in lactose_free_items {
//                        string_to_print.append(item+"\n")
//                    }
//                }

            }
        }
        //self.customInfoWindow?.body_label.text = string_to_print
        marker.map = mapView
        return false
    }
    
    //func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        //return self.customInfoWindow
    //}
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        locationManager.startUpdatingLocation()
        if self.home_data != nil {
            //self.updateData()
        }
        //else {
            //self.callHomeAPI()
            //viewWillAppear(true)
        //}
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logout_tapped(_ sender: Any) {
        //let fbLoginManager:FBSDKLoginManager = FBSDKLoginManager(
        let view_controller = board.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        ViewController.shared.fbLoginManager.logOut()
        self.present(view_controller, animated: true, completion: nil)
    }
    
    func callPreferencesAPI() -> Preferences {
        print("preference called")
        var preferences = Preferences(status: "not ok",gluten_free: false, vegan: false, scd: false, nuts: false, lactose: false)
        let Url = String(format: "https://healthyeatingapp.com/api/preferences")
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
        print("preferences", preferences)
        return preferences
    }
    
    func callHomeAPI() {
        let Url = String(format: "https://healthyeatingapp.com/api/restaurants")
        guard let serviceUrl = URL(string: Url) else { return }
        print("location here?", self.location?.coordinate.longitude)
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
                    print("self.home_data", self.home_data)
                    print("first name",self.home_data?.restaurant_list[0].name)
                    self.updateData()
                }catch {
                    print(error)
                }
                //self.updateData()
            }
            //self.updateData()
            }.resume()
        //self.updateData()
        print("done executing")
        
        //self.updateData()
        //let position = CLLocationCoordinate2D(latitude: 37, longitude: -122)
        //let london = GMSMarker(position: position)
        //london.title = "London"
        //london.snippet = "Res. C\ntesting address\nhttps://google.com\nGluten Free\nsalad, apple, bread\nVegan\nsalad, apple, bread\nSCD\nsalad, apple, bread\nNo Nuts\nsalad, apple, bread"
        //london.map = mapView
        //let marker = GMSMarker()
        //marker.position = position
    }
    
    
    func updateData() {
        //let marker = GMSMarker()
        print("started to execute")
        print("self.home_data", self.home_data)
        print("first name final",self.home_data!.restaurant_list[0].name)
        //var marker2 = GMSMarker()
        for restaurant in (self.home_data?.restaurant_list)! {
        //let restaurant = self.home_data!.restaurant_list[0]
            //let marker = GMSMarker()
            print(restaurant.name)
            print(restaurant.address + "\n")
            let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(restaurant.latitude), longitude: CLLocationDegrees(restaurant.longitude))
            let marker = GMSMarker(position: position)
            marker.title = restaurant.name
            var marker_string = restaurant.address + "\n"
            let last_item = restaurant.menu_items[restaurant.menu_items.count - 1].item_name
            for item in restaurant.menu_items {
                if(item.item_name != last_item) {
                    marker_string += item.item_name + ", "
                }
                else {
                    marker_string += item.item_name
                }
            }
            marker.snippet = marker_string
            
            marker.position = position
            print(marker.position)
            marker.map = self.mapView
            print("title:", marker.title)
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
        print("location!", self.location?.coordinate.longitude)
        
        // 7
        mapView.camera = GMSCameraPosition(target: (self.location?.coordinate)!, zoom: 10, bearing: 0, viewingAngle: 0)
        
        // 8
        locationManager.stopUpdatingLocation()
        if (!home_called) {
            self.callHomeAPI()
            //self.viewWillAppear(true)
            home_called = true
            //self.updateData()
        }
    }
}

