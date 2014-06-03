//
//  TodayViewController.swift
//  Widget
//
//  Created by Ruslan Gumennyi on 03/06/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

import UIKit
import NotificationCenter
import MapKit
import CoreLocation

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var mapImageView : UIImageView
    @IBOutlet var lastUpdateLabel : UILabel
  
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize.height = 350
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadCachedData()
        self.updateMap()
    }
    
    func loadCachedData() {
        var date : AnyObject? = (NSUserDefaults.standardUserDefaults().objectForKey("updateDate"))
        var lastImage : AnyObject? = (NSUserDefaults.standardUserDefaults().objectForKey("lastImage"))
        
        if date && lastImage {
            self.mapImageView.image = UIImage(data: (lastImage as NSData))
            self.setUpdateDate(date as NSDate)
        }
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.loadCachedData()
            completionHandler(self.updateMap() ? NCUpdateResult.NewData : NCUpdateResult.Failed)
            })
    }
    
    @IBAction func updateButtonTapped(sender : AnyObject) {
        self.updateMap()
    }
    
    func updateMap() -> Bool {
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
        
        var imageUrlString = NSString(format: "http://static-maps.yandex.ru/1.x/?ll=%@,%@&spn=%@,%@&size=300,250&l=map,trf", lon!, lat!, spn!, spn!)
        var imageUrl : NSURL = NSURL.URLWithString(imageUrlString)
        var imageData : NSData? = NSData.dataWithContentsOfURL(imageUrl, options: NSDataReadingOptions.DataReadingMapped, error: nil)
        var image : UIImage? = UIImage(data : imageData)
        
        if (image) {
            self.mapImageView.image = image
            
            var date = NSDate.date()
            self.setUpdateDate(date)
            
            NSUserDefaults.standardUserDefaults().setObject(UIImagePNGRepresentation(image), forKey: "lastImage")
            NSUserDefaults.standardUserDefaults().setObject(date, forKey: "updateDate")
            return true
        } else {
            return false
        }
    }
    
    func setUpdateDate(updateDate : NSDate) {
        var formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.locale = NSLocale.currentLocale()
        formatter.timeStyle = NSDateFormatterStyle.MediumStyle
        var title = NSString(format: "%@", formatter.stringFromDate(updateDate))
        self.lastUpdateLabel.text = title
    }
    
    @IBAction func imageTapped(sender : AnyObject) {
        self.extensionContext.openURL(NSURL(string: "traffic://"), completionHandler: nil)
    }
}
