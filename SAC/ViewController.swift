//
//  ViewController.swift
//  SAC
//
//  Created by Andrei Bosco on 04/10/15.
//  Copyright © 2015 Andrei Bosco. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!

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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func useCameraRoll() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func useCamera() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .Camera
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func photoFilter(filterName: String) {
        let originalImage = CIImage(image: imageView.image!)
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()
        filter?.setValue(originalImage, forKey: kCIInputImageKey)
        
//        let context = CIContext(options: nil)
//        let outputImage = context.createCGImage(filter.outputImage, fromRect: filter?.outputImage?.extent())
        let outputImage = filter?.outputImage
        let newImage = UIImage(CIImage: outputImage!)
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

}

