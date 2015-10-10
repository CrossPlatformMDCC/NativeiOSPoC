//
//  ViewController.swift
//  SAC
//
//  Created by Andrei Bosco on 04/10/15.
//  Copyright © 2015 Andrei Bosco. All rights reserved.
//

import UIKit
import AVFoundation

//G+
import AddressBook
import MediaPlayer
import AssetsLibrary
import CoreLocation
import CoreMotion

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GPPSignInDelegate, CLLocationManagerDelegate {
    
    var signIn : GPPSignIn?
    var latitude : String?
    var longitude : String?
    let locationManager = CLLocationManager();
    var photoIndex : Int = 0;
    var photoArray = [UIImage]();
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        photoArray.append(imageView.image!); // salvando imagens em array (FIXME: gambiarra, usa muita memoria)
        dismissViewControllerAnimated(true, completion: nil)
        
//        photoIndex++;
//        print(photoIndex);
        photoIndex = photoArray.count;
        updatePhotoLabel();
    }
    
    @IBAction func useCameraRoll() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func useCamera() {
//        let picker = UIImagePickerController()
//        
//        picker.delegate = self
//        picker.sourceType = .Camera
//        
//        presentViewController(picker, animated: true, completion: nil)
        imageView.image = photoArray[0];
        photoIndex = 1;
        updatePhotoLabel();
    }
    
    @IBAction func prevPhoto() {
        showPhoto(photoIndex-1)
    }
    
    @IBAction func nextPhoto() {
        showPhoto(photoIndex+1)
    }
    
    func showPhoto(var index : Int) {
        if (index >= photoArray.count) {
            index = 0
        } else if (index < 0) {
            index = photoArray.count - 1
        }
        imageView.image = photoArray[index];
//        if (photoArray.count > 0) {
//            updatePhotoLabel()
//        }
        photoIndex = index;
        updatePhotoLabel()
//        if(index >= photos.length)
//        index = 0;
//        if(index < 0)
//        index = photos.length-1;
//        var img = document.getElementById('camera_image');
//        img.src = photos[index];
//        photoIndex = index;
//        if(photos.length > 0)
//        $("#nImage").html(index+1 + " de " + photos.length);
    }
    
    func updatePhotoLabel() {
        imageLabel.text = String(photoIndex) + " de " + String(photoArray.count);
    }
    
    func photoFilter(filterName: String) {
        let originalImage = CIImage(image: imageView.image!)
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()
        filter?.setValue(originalImage, forKey: kCIInputImageKey)
        let newImage = UIImage(CGImage: CIContext(options:nil).createCGImage((filter?.outputImage)!, fromRect: (filter?.outputImage!.extent)!))
        imageView.image = newImage
    }
    
    @IBAction func filterSepia() {
        photoFilter("CISepiaTone")
    }
    
    @IBAction func filterMono() {
        photoFilter("CIPhotoEffectMono")
    }
    
    @IBAction func filterInvert() {
        photoFilter("CIColorInvert")
    }
    
    //MARK: G+
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        //NSLog("Received error %@ and auth object %@", error, auth);
    }
    
    func didDisconnectWithError(error: NSError!) {
        
    }
    
    func loginGooglePlus() {
        signIn = GPPSignIn.sharedInstance()
        signIn?.shouldFetchGooglePlusUser = true
        signIn?.clientID = "686168425382-8be7kjup8eev5ggs7ttdd1jauj1fesju.apps.googleusercontent.com"
        signIn?.scopes = [kGTLAuthScopePlusLogin]
        signIn?.delegate = self
        signIn?.authenticate()
    }
    
    @IBAction func shareGooglePlus(sender: AnyObject) {
        loginGooglePlus()
        
        let shareDialog = GPPShare.sharedInstance().nativeShareDialog();
        shareDialog.attachImage(imageView.image);
        shareDialog.setPrefillText("Teste");
        shareDialog.open();
    }
    
    @IBAction func shareLocation(sender: AnyObject) {
        loginGooglePlus()
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                self.displayLocationInfo(pm)
                // print("Lat:" + self.latitude!)
                // print("Log:" + self.longitude!)
                
                // G+
                let shareDialog = GPPShare.sharedInstance().nativeShareDialog();
                let positionLink = "https://maps.google.com/maps?q=" + self.latitude! + "," + self.longitude!;
                // print("URL:" + positionLink)
                shareDialog.setURLToShare(NSURL(string: positionLink));
                shareDialog.setPrefillText("Posição");
                shareDialog.open();
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        locationManager.stopUpdatingLocation()
        latitude = String(placemark.location!.coordinate.latitude)
        longitude = String(placemark.location!.coordinate.longitude)
        // print(placemark.country)
        // print(placemark.location?.coordinate.latitude)
        // print(placemark.location?.coordinate.longitude)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location: " + error.localizedDescription)
    }
    
}

