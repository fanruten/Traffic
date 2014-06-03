//
//  ViewController.swift
//  Traffic
//
//  Created by Ruslan Gumennyi on 03/06/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

import UIKit
import NotificationCenter
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet var mapView : MKMapView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPostionFromFile()
    }
    
    func setupPostionFromFile() {
        var lat : NSNumber? = 59.9690273
        var lon : NSNumber? = 30.35
        var spn : NSNumber? = 0.2
        
        var dictUrl : NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.96GT47C53G.traffic")
        dictUrl = dictUrl.URLByAppendingPathComponent("settings.dict")
        
        let dict : NSDictionary? = NSDictionary(contentsOfURL: dictUrl)
        if (dict) {
            lat = dict!["lat"] as? NSNumber
            lon = dict!["lon"] as? NSNumber
            spn = dict!["spn"] as? NSNumber
        }
        
        self.mapView.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat!.doubleValue, longitude: lon!.doubleValue),
            span: MKCoordinateSpan(latitudeDelta: spn!.doubleValue, longitudeDelta: spn!.doubleValue)
        )
    }
    
    @IBAction func updateWidgetButtonTapped(sender : AnyObject) {
        var dict : NSMutableDictionary = NSMutableDictionary()
        dict["spn"] = self.mapView.region.span.latitudeDelta
        dict["lat"] = self.mapView.region.center.latitude
        dict["lon"] = self.mapView.region.center.longitude
        
        var dictUrl : NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.96GT47C53G.traffic").URLByAppendingPathComponent("settings.dict")
        dict.writeToFile(dictUrl.path, atomically: true)
 
        NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "com.e-legion.Traffic.Widget")
    }
}

