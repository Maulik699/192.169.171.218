//
//  ViewController.swift
//  BoardsInterview
//
//  Created by Maulik Vekariya on 12/8/17.
//  Copyright © 2017 Maulik Vekariya. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON

class ViewController: UIViewController,CLLocationManagerDelegate , GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate
{

    // OUTLETS
    @IBOutlet weak var googleMapsView: GMSMapView!
    
    // VARIABLES
    var locationManager = CLLocationManager()
    let searchRadius: Double = 8046.72 // 5 miles
    var searchedTypes = "hospital+and+restaurant"
    var nextPageToken = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        
        self.title = "Near by places"
        
        let searchButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(openSearchAddress(_:)))
        
        self.navigationItem.rightBarButtonItem = searchButton
        
        let btnscreen2 : UIBarButtonItem = UIBarButtonItem(title: "Screen2", style: .plain, target: self, action: #selector(goToSecondScreen(_:)))
        
        self.navigationItem.leftBarButtonItem = btnscreen2
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        initGoogleMaps()
        
        // Do any additional setup after loading the view.
    }

    @objc func goToSecondScreen(_ sender: UIBarButtonItem)
    {
        let sView = SocialView(nibName: "SocialView", bundle: nil)
        self.navigationController?.pushViewController(sView, animated: true)
    }
    
    func initGoogleMaps() {
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 14.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.googleMapsView.camera = camera
        
        self.googleMapsView.delegate = self
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: CLLocation Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 11.0)
        self.searchNearBy(latt: (location?.coordinate.latitude)!, long: (location?.coordinate.longitude)!)
        
        self.googleMapsView.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    // MARK: GMSMapview Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.googleMapsView.isMyLocationEnabled = true
        
        
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        self.googleMapsView.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
        }
        
    }
    
    // MARK: GOOGLE AUTO COMPLETE DELEGATE
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace)
    {
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 5.0)
        self.googleMapsView.camera = camera
        self.dismiss(animated: true) {
            self.googleMapsView.clear()

            self.searchNearBy(latt: place.coordinate.latitude, long: place.coordinate.longitude)
        }// dismiss after select place
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("ERROR AUTO COMPLETE \(error)")
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
    @objc func openSearchAddress(_ sender: UIBarButtonItem)
    {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    // MARK: - SearchNearByMethods
    
    func searchNearBy(latt : CLLocationDegrees, long : CLLocationDegrees)
    {
        
        var urlStr = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(searchedTypes)&location=\(latt),\(long)&radius=\(searchRadius)&key=\(googleApiKey)"
        
        if !nextPageToken.isEmpty
        {
            urlStr = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(searchedTypes)&location=\(latt),\(long)&radius=\(searchRadius)&key=\(googleApiKey)&pagetoken=\(nextPageToken)"
        }

        AFWrapper.requesting(methodRequest: .get, URLString: urlStr, onSuccess: { (response) in
            
            
            let dictResponse = response as! NSDictionary
            print(dictResponse)

            let arrResults = dictResponse.object(forKey: "results") as! NSArray
            
            for place in arrResults
            {
                let marker = GMSMarker()
                
                let markerImage = UIImage(named: "mapMarker")!.withRenderingMode(.alwaysTemplate)
                
                let markerView = UIImageView(image: markerImage)
                markerView.tintColor = UIColor.red
                
                let json = JSON(place)
                
                let lat = json["geometry"]["location"]["lat"].doubleValue as CLLocationDegrees
                let lng = json["geometry"]["location"]["lng"].doubleValue as CLLocationDegrees
                
                marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                
                marker.iconView = markerView
                marker.title = json["name"].stringValue
                marker.snippet = json["vicinity"].stringValue
                marker.map = self.googleMapsView
                
                //comment this line if you don't wish to put a callout bubble
                self.googleMapsView.selectedMarker = marker
                
            }
            
            if (dictResponse.object(forKey: "next_page_token") != nil)
            {
                if dictResponse.object(forKey: "next_page_token") as! String != self.nextPageToken
                {
                    self.nextPageToken = dictResponse.object(forKey: "next_page_token") as! String
                    self.searchNearBy(latt: latt, long: long)
                }
            }
            
                
            
            
            
        }) { (error) in
            print(error)
        }
    }
    
    func imageWithView(view:UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
