//
//  ViewController.swift
//  assignment3
//
//  Created by Student on 2017-04-12.
//  Copyright © 2017 Student. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var timeStamp: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        //delegating UIImagePckerController to itself
        image.delegate = self
        
        //delegating CLLocationManager to itself
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.stopMonitoringSignificantLocationChanges()
        
        updateTime()
    }
    
    func updateTime() {
        let tap = UITapGestureRecognizer(target: self, action:
            #selector(ViewController.updateTime))
        timeStamp.isUserInteractionEnabled = true
        timeStamp.addGestureRecognizer(tap)
        
        getTime()//execute time function
    }
    

//Start of time stamp block------------------------------------------
    
    func getTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        let timeString =
        "The date and time is: \(dateFormatter.string(from: Date() as Date))"
        
        timeStamp.text = String(timeString)
    }
    
//End of time stamp block------------------------------------------
    
    
    
    
    
//Start of image picker block------------------------------------------
    
    @IBOutlet weak var imageView: UIImageView!
    let image = UIImagePickerController()
    
    //Button to get a picture from photoLoabrary
    @IBAction func post(_ sender: Any) {
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
//End of image picker block----------------------------------
   
    

    
    
    
//Start of text view editing--------------------------------
    
    @IBOutlet weak var textDescription: UITextField!
    
//End of text view editing--------------------------------
    
    
    

    
//Start of location picker block------------------------------
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet weak var locationName: UILabel!

    @IBAction func locationPicker(_ sender: Any) {
        getLocation()
    }
    
    func getLocation(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            currentLocation = locationManager.location
            
            let longitude :CLLocationDegrees = currentLocation.coordinate.longitude
            let latitude :CLLocationDegrees = currentLocation.coordinate.latitude
            let location = CLLocation(latitude: latitude, longitude: longitude)
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                if (placemarks?.count)! > 0 {
                    let pm = placemarks?[0] as CLPlacemark!
                    
                    self.locationName.text =
                        (pm?.country)! + ", " + (pm?.locality)! + ", " + (pm?.subLocality)! + ", " + "\n" +
                        (pm?.thoroughfare)! + " " + (pm?.subThoroughfare)! + ", " + (pm?.postalCode)!
                        
                    print(self.locationName.text as Any)
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
        else{
            locationManager.requestWhenInUseAuthorization()
            getLocation()
        }
    }
//End of location picker block------------------------------


    
    
    
//Start of sync to cloud block--------------------------------
    
    @IBAction func cloudSync(_ sender: Any) {
        syncToCloud()
    }
    
    func syncToCloud(){
        //Conversion of the picture to the string as all fieldes in the cloud storage were String
        let renderer = UIGraphicsImageRenderer(size: imageView.bounds.size)
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        
        let userImage:UIImage = image
        let imageData:NSData = UIImagePNGRepresentation(userImage)! as NSData
        let dataImage = imageData.base64EncodedString(options: .lineLength64Characters)
        //End of conversion
        
        //Uploading process
        let testObject = PFObject(className: "TestObject")
        testObject["picture"] = dataImage
        testObject["text"] = textDescription.text
        testObject["dateTime"] = timeStamp.text
        testObject["location"] = locationName.text
        testObject.saveInBackground { (result, error) -> Void in
            print("Object has been saved.")
        }
    }
    
//End of sync to cloud block--------------------------------
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

