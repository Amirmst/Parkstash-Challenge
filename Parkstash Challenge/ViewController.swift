//
//  ViewController.swift
//  Parkstash Challenge
//
//  Created by amir reza mostafavi on 1/23/18.
//  Copyright © 2018 Amir Mostafavi. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var pinLocationButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var leadingConstraintMenu: NSLayoutConstraint!
    @IBOutlet weak var slideOverMenu: UIView!
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var searchedLocation: CLLocation?
    
    var menuShowing = false
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        slideOverMenu.layer.shadowOpacity = 1
        slideOverMenu.layer.shadowRadius = 6
        pinningButtons(isHidden: true)
        DataManager.shared.loadData()
        
        // Sets the initial location to the first location in dummy data
        let initialLocation = DataManager.shared.data[0]
        zoomInOnLocation(location: initialLocation, regionRadius: 2000)
        pinAllGivenLocations(dataSet: DataManager.shared.data)
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

    // Happens when user presses search button
    @IBAction func searchButtonPressed(_ sender: Any) {
        pinningButtons(isHidden: true)
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    
    
    // Happens after user clicks on search to find the typed location
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Ignoring interations
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Loading indicator
        let loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.center = self.view.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        self.view.addSubview(loadingIndicator)
        
        // Hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // Perform search
        perfromSearch(searchBar: searchBar, loadingIndicator: loadingIndicator)
    }
    

    
    // CLOSE button has tag value 0, and PIN THIS LOCATION has tag value of 1
    @IBAction func pinningButtonPressed(_ sender: AnyObject) {
        if sender.tag == 0 {
            // Close button pressed
            pinningButtons(isHidden: true)
        } else {
            // User wants to pin location
            annotateLocation(location: searchedLocation!)
            // Add the pinned location to data set
            DataManager.shared.data.insert(searchedLocation!, at: 0)
            DataManager.shared.saveData()
        }
        pinningButtons(isHidden: true)
    }
    
    
    
    // Happens when menu button is pressed
    @IBAction func showMenuPressed(_ sender: Any) {
        if (menuShowing){
            // Slide out
            leadingConstraintMenu.constant = -290
            mapViewIsActive(isActive: true)
            searchButton.isEnabled = true
        } else {
            // Slide back in
            leadingConstraintMenu.constant = 0
            mapViewIsActive(isActive: false)
            searchButton.isEnabled = false
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        
        menuShowing = !menuShowing
    }
    
    
    
    // performs searching given a UI search bar and Activity indicator
    func perfromSearch(searchBar: UISearchBar, loadingIndicator: UIActivityIndicatorView){
        // Creates search request
        let searchReq = MKLocalSearchRequest()
        searchReq.naturalLanguageQuery = searchBar.text
        
        let activeSearchReq = MKLocalSearch(request: searchReq)
        activeSearchReq.start { (result, error) in
            loadingIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if result == nil {
                let alert = UIAlertController(title: "Location not found", message: "We were unable to find this location.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                // Getting data
                let latitude = result?.boundingRegion.center.latitude
                let longitude = result?.boundingRegion.center.longitude
                
                let location = CLLocation(latitude: latitude!, longitude: longitude!)
                self.searchedLocation = location
                self.zoomInOnLocation(location: location, regionRadius: 3000)
                self.pinningButtons(isHidden: false)
            }
        }
    }
    
    
    
    // Shows pins on given locations from the data set.
    func pinAllGivenLocations(dataSet: [CLLocation]){
        for location in dataSet {
            annotateLocation(location: location)
        }
    }
    
    
    
    // Focuses the map view around a given locaion
    func zoomInOnLocation(location: CLLocation, regionRadius: CLLocationDistance ){
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(region, animated: true)
    }
    
    
    
    // Given a location, drops a pin on that location
    func annotateLocation(location: CLLocation){
        let locationCoords = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoords
        mapView.addAnnotation(annotation)
    }
    
    
    
    // Showws and hides pinning buttons
    func pinningButtons(isHidden: Bool){
        cancelButton.isHidden = isHidden
        pinLocationButton.isHidden = isHidden
    }
    
    
    
    // Controls the state of mapView
    func mapViewIsActive(isActive: Bool){
        mapView.layer.opacity = (isActive) ? 1 : 0.4
        mapView.isZoomEnabled = isActive;
        mapView.isScrollEnabled = isActive;
        mapView.isUserInteractionEnabled = isActive;
    }
}

