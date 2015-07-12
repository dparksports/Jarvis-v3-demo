//
//  ViewController.swift
//  Cloud
//
//  Created by engineering on 5/24/15.
//  Copyright (c) 2015 magicpoint. All rights reserved.
//

import CoreLocation
import StoreKit
import MapKit
import UIKit

class ViewController: UIViewController,
MKMapViewDelegate, SKStoreProductViewControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolbar: UIToolbar!
    var phoneNumberToLocate:String? = nil
    let notificationCenter = NSNotificationCenter .defaultCenter()
    lazy var numberFormatter = NBAsYouTypeFormatter(code: ())
    lazy var phoneNumberUtil = NBPhoneNumberUtil.sharedInstance()
    var pulsatingItem:PulsatingItem? = nil
    var pulsatingButton:UIButton? = nil
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        self.addUserLocationItem()

        pulsatingButton = UIButton(frame: CGRectMake(0, 0, 100, 20))
        pulsatingButton?.setTitle("iPhone", forState: UIControlState.Normal)
        pulsatingButton?.setTitleColor(self.view.tintColor, forState: UIControlState.Highlighted)
        pulsatingButton?.addTarget(self, action: "askOwnerNumber:", forControlEvents: UIControlEvents.TouchUpInside)
        pulsatingItem = PulsatingItem(customView: pulsatingButton!)
        self.navigationItem.leftBarButtonItem = pulsatingItem
        
//        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
//        indicator.startAnimating()
//        self.navigationItem.rightBarButtonItem = SubscriptionItem(customView: indicator)
        
        notificationCenter.addObserver(self, selector:"handleRetrieveMessage:", name:GERetrieveMessage, object:nil)
//        self.navigationController?.navigationBar.clipsToBounds = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.startCallEngine(self)
        
        let book = Phonebook.sharedInstance()
        book.loadMyNumberAndToken()
        if book.myPhoneNumber == nil {
            pulsatingItem?.pulsingHaloLayer.hidden = false
            MGAppleServices.speakCondition("Hello Jarvis. This is Siri. I will be your voice interface. ")
        } else {
            self.normalizePulsatingItem()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
       return UIStatusBarStyle.Default
    }
    
    func addUserLocationItem() {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)

        let item = MKUserTrackingBarButtonItem(mapView: mapView)
        var items = toolbar.items
        items?.insert(item, atIndex: 0)
        toolbar.setItems(items, animated: true)
    }
    
    func normalizePulsatingItem() {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        
        pulsatingItem?.pulsingHaloLayer.hidden = true
        pulsatingButton?.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        pulsatingButton?.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted)
    }
    
    // MARK: NSNotificationCenter
    
    @objc func handleRetrieveMessage(notification:NSNotification!){
        let tag = notification.userInfo?.keys.first as! String
        let user = notification.userInfo?.values.first as! User
        NSLog("%@: %@ userInfo:%@", reflect(self).summary, __FUNCTION__, notification.userInfo!)
        
        if let coordinate = user.coordinateUser, title = user.phoneNumber {
            self.addMapAnnotation(coordinate: coordinate, title: title)
        }
    }
    
    func addMapAnnotation(coordinate coordinate:CLLocationCoordinate2D, title:String) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        
        dispatch_async(dispatch_get_main_queue(), {
            let annotation = PhotoAnnotation(imagePath: nil, title: title, coordinate: coordinate)
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
        })
        
        dispatch_async(dispatch_get_main_queue(), {
            MGAppleServices.zoomToLocationCoordinate(coordinate, withMap: self.mapView)
        })
    }
    
    // MARK: MKMapViewDelegate
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        if annotation.isKindOfClass(PhotoAnnotation) {
            let annotationID = "annotationID"
//            var pinView:MKPinAnnotationView? =  mapView .dequeueReusableAnnotationViewWithIdentifier(annotationID) as? MKPinAnnotationView
            
            var pinView:SVPulsingAnnotationView? =  mapView .dequeueReusableAnnotationViewWithIdentifier(annotationID) as? SVPulsingAnnotationView
            
            
            
            if let pinAnnotationView = pinView {
                pinAnnotationView.annotation = annotation;
                return pinAnnotationView
            } else {
                let pulsingAnnotationView = SVPulsingAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
                pulsingAnnotationView.annotationColor = UIColor(red: 0.678431, green: 0, blue: 0, alpha: 1)
                pulsingAnnotationView.canShowCallout = true
                return pulsingAnnotationView
                
//                let button = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
//                button.addTarget(self, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
//                
//                let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
//                pinAnnotationView.pinColor = MKPinAnnotationColor.Green
//                pinAnnotationView.animatesDrop = true
//                pinAnnotationView.canShowCallout = true
//                pinAnnotationView.draggable = false
//                pinAnnotationView.rightCalloutAccessoryView = button
//                return pinAnnotationView
            }
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }
    
    // MARK: SKStoreProductViewControllerDelegate
    func productViewControllerDidFinish(viewController: SKStoreProductViewController!) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        viewController.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func retrieveVendorID() -> String?{
        var identifierForVendor:NSUUID? = UIDevice.currentDevice().identifierForVendor
        if let id = identifierForVendor {
            let idString:String = id.UUIDString
            NSLog("%@: %@: identifierForVendor:%@", reflect(self).summary, __FUNCTION__, idString)
            return idString
        } else {
            return nil
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        //        let phoneNumber = "626-347-7076"
        //        let phoneNumber = "818-397-5693"
        return true
    }
    
    func editingChanged(textField: UITextField) {
        NSLog("%@: %@: textField.text:%@", reflect(self).summary,__FUNCTION__, textField.text!)
        self.phoneNumberToLocate = phoneNumberUtil.normalizeDigitsOnly(textField.text)
        
        if let string = self.phoneNumberToLocate {
            self.numberFormatter?.inputString(string)
            var description = self.numberFormatter?.description
            NSLog("%@: %@: numberFormatter:%@", reflect(self).summary,__FUNCTION__, description!)
            textField.text = description!
        }
    }
    
    func editingChangedByOwner(textField: UITextField) {
        NSLog("%@: %@: textField.text:%@", reflect(self).summary,__FUNCTION__, textField.text!)
        self.phoneNumberToLocate = phoneNumberUtil.normalizeDigitsOnly(textField.text)
        
        if let string = self.phoneNumberToLocate {
            self.numberFormatter?.inputString(string)
            let description = self.numberFormatter?.description
            NSLog("%@: %@: numberFormatter:%@", reflect(self).summary,__FUNCTION__, description!)
            textField.text = description!
        }
    }
    
    // MARK: IBAction

    @IBAction func askOwnerNumber(sender: AnyObject) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        
        let book = Phonebook.sharedInstance()
        book.loadMyNumberAndToken()
        if book.myPhoneNumber == nil {
            MGAppleServices.speakCondition("You have an incoming notification. Would you like to confirm it? Please confirm it by entering your iPhone number.")
        }
        
        MGSaltShaker.gibberishTest()
        
        let controller = UIAlertController(title: nil, message: "Set your phone number", preferredStyle:UIAlertControllerStyle.Alert)
        
        let actionLocate = UIAlertAction(title: "Set", style: UIAlertActionStyle.Default, handler: {[weak self] action in
            if let phoneNumber = self?.phoneNumberToLocate {
                NSLog("%@: %@: phoneNumber:%@", reflect(self).summary,__FUNCTION__, phoneNumber)
                Singleton.gravityEngine.userOwner = User(number: phoneNumber)
                
                let book = Phonebook.sharedInstance()
                book.myPhoneNumber = phoneNumber
                book.saveMyNumberAndToken()
                self?.normalizePulsatingItem()
            }
        })
        
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {action in
            if let phoneNumber = self.phoneNumberToLocate {
                NSLog("%@: %@: phoneNumber:%@", reflect(self).summary,__FUNCTION__, phoneNumber)
            }
        })
        
        controller.addAction(actionLocate)
        controller.addAction(actionCancel)
        controller.addTextFieldWithConfigurationHandler({textField in
            self.numberFormatter!.inputString("7145551212")
            let description = self.numberFormatter!.description
            textField.placeholder = description
            
            let book = Phonebook.sharedInstance()
            if let myPhoneNumber = book.myPhoneNumber {
                self.numberFormatter!.inputString(myPhoneNumber)
                let description = self.numberFormatter!.description
                textField.text = description
            } else {
                textField.text = ""
            }
            
            textField.delegate = self
            textField.keyboardType = UIKeyboardType.PhonePad
            textField.clearButtonMode = UITextFieldViewMode.Always
            textField.addTarget(self, action: "editingChangedByOwner:", forControlEvents: UIControlEvents.EditingChanged)
        })
        self.presentViewController(controller, animated: true, completion: {
        })
    }
    
    @IBAction func locatePhoneNumber(sender: AnyObject) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        
        let controller = UIAlertController(title: nil, message: "Enter iPhone number to locate", preferredStyle:UIAlertControllerStyle.Alert)
        
        let actionLocate = UIAlertAction(title: "Locate", style: UIAlertActionStyle.Default, handler: {action in
            if let phoneNumber = self.phoneNumberToLocate {
                NSLog("%@: %@: phoneNumber:%@", reflect(self).summary,__FUNCTION__, phoneNumber)
                Singleton.gravityEngine.locateUser(phoneNumber)
            }
        })
        
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {action in
            if let phoneNumber = self.phoneNumberToLocate {
                NSLog("%@: %@: phoneNumber:%@", reflect(self).summary,__FUNCTION__, phoneNumber)
            }
        })
        
        controller.addAction(actionLocate)
        controller.addAction(actionCancel)
        controller.addTextFieldWithConfigurationHandler({textField in
            self.numberFormatter!.inputString("4155551212")
            let description = self.numberFormatter!.description
            textField.delegate = self
            textField.placeholder = description
            textField.keyboardType = UIKeyboardType.PhonePad
            textField.clearButtonMode = UITextFieldViewMode.Always
            textField.addTarget(self, action: "editingChanged:", forControlEvents: UIControlEvents.EditingChanged)
        })
        self.presentViewController(controller, animated: true, completion: {
            MGAppleServices.speakCondition("Jarvis can triangulate any iPhone around the world.  Enter a phone number to locate.")
        })
    }
    
    @IBAction func subscribe(sender: AnyObject) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        Singleton.gravityEngine.cloudKitManager.subscribe({(error) in
            if let ckError = error {
                NSLog("%@: %@ ckError:%@", reflect(self).summary, __FUNCTION__, ckError)
            } else {
                NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
            }
        })
    }
    
    @IBAction func postMessage(sender: AnyObject) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        self.subscribe(self)
        Singleton.gravityEngine.cloudKitManager.postMessage()
        Singleton.gravityEngine.cloudKitManager.checkSubscription()
    }

    @IBAction func convertMessage(sender: AnyObject) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        Singleton.gravityEngine.cloudKitManager.convertString()
        Singleton.gravityEngine.cloudKitManager.unsubscribe()
    }

    @IBAction func registerLocationManager(sender: AnyObject) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
//        locationManager.requestAlwaysAuthorization()
    }
    
    @IBAction func registerCallCenter(sender: AnyObject) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
//        callManager.registerCallCenter()
    }
    
    @IBAction func startCallEngine(sender: AnyObject) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        if !Singleton.gravityEngine.isStarted {
            var controller:UIAlertController? = Singleton.gravityEngine.startEngine()
            if let alert = controller {
                self.presentViewController(alert, animated: true, completion: {
                    NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
                })
            }
        }
    }
    
    @IBAction func addMapAnnotation(sender: AnyObject) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        
        self.addMapAnnotation(coordinate: mapView.centerCoordinate, title: "Hero")
    }
    
    @IBAction func speakJarvis(sender: AnyObject) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        
        MGAppleServices.speakCondition("Hello Jarvis. This is Siri. I will be your voice interface. ")
    }
    
    @IBAction func showAboutController(sender: AnyObject) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        let controller = MGAboutController()
        controller.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        self.presentViewController(controller, animated: true, completion:
            {})
    }

    @IBAction func openAppStore(sender: AnyObject) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        let parameters = [
            SKStoreProductParameterITunesItemIdentifier:NSNumber(int: 577770349)
        ]
        let controller = SKStoreProductViewController()
        controller.delegate = self
        controller.loadProductWithParameters(parameters, completionBlock: {
            (success:Bool, error: NSError?) -> Void in
            if success {
                self.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
                self.presentViewController(controller, animated: true, completion: nil)
            } else {
                NSLog("%@: %@: error:%@", reflect(self).summary, __FUNCTION__, error!)
            }
            })
    }
}

