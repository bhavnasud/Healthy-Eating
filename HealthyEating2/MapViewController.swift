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




class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    private let locationManager = CLLocationManager()
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    var tappedMarker : GMSMarker?
    var customInfoWindow : CustomInfoWindow?
    var home_data: Restauraunts?
    
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
        // Do any additional setup after loading the view.
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("here is title", marker.title)
        self.customInfoWindow = CustomInfoWindow().loadView()
        self.customInfoWindow?.body_label.numberOfLines = 12
        self.customInfoWindow?.title_label.text = marker.title
        var string_to_print = ""
        for restauraunt in (home_data?.restauraunt_list)! {
            if restauraunt.name == marker.title {
                print("testing,", restauraunt.name)
                var gluten_free_items: [String] = []
                var vegan_items: [String] = []
                var scd_items: [String] = []
                var nut_free_items: [String] = []
                var lactose_free_items: [String] = []
                
                for item in (restauraunt.menu_items) {
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
                self.home_data = try JSONDecoder().decode(Restauraunts.self, from: dataResponse)
                //print(home_data)
                
                
                for restauraunt in (self.home_data?.restauraunt_list)! {
                    print(restauraunt.name)
                    print(restauraunt.address + "\n")
                    let marker = GMSMarker()
                    marker.title = restauraunt.name
                    let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(restauraunt.latitude), longitude: CLLocationDegrees(restauraunt.longitude))
                    marker.position = position
                    print(marker.position)
                    marker.map = self.mapView
                    print("title:", marker.title)
                }
                
                let restauraunt_three = self.home_data?.restauraunt_list[2]
                print(restauraunt_three?.name)
                print(restauraunt_three?.address)
                print(restauraunt_three?.website)
                
                var gluten_free_items: [String] = []
                var vegan_items: [String] = []
                var scd_items: [String] = []
                var nut_free_items: [String] = []
                var lactose_free_items: [String] = []
                
                for item in (restauraunt_three?.menu_items)! {
                    if item.gluten_free {gluten_free_items.append(item.item_name)}
                }
                for item in (restauraunt_three?.menu_items)! {
                    if item.vegan {vegan_items.append(item.item_name)}
                }
                for item in (restauraunt_three?.menu_items)! {
                    if item.scd {scd_items.append(item.item_name)}
                }
                for item in (restauraunt_three?.menu_items)! {
                    if item.nuts {nut_free_items.append(item.item_name)}
                }
                for item in (restauraunt_three?.menu_items)! {
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
        let position = CLLocationCoordinate2D(latitude: 37, longitude: -122)
        //let london = GMSMarker(position: position)
        //london.title = "London"
        //london.snippet = "Res. C\ntesting address\nhttps://google.com\nGluten Free\nsalad, apple, bread\nVegan\nsalad, apple, bread\nSCD\nsalad, apple, bread\nNo Nuts\nsalad, apple, bread"
        //london.map = mapView
        let marker = GMSMarker()
        marker.position = position
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
        guard let location = locations.first else {
            return
        }
        
        // 7
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        // 8
        locationManager.stopUpdatingLocation()
    }
}

