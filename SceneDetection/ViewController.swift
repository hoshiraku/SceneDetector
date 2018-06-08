//
//  ViewController.swift
//  SceneDetection
//
//  Created by hoshiraku on 08.06.18.
//  Copyright © 2018 hoshiraku. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var imagePickerController : UIImagePickerController!
    
    var selectedImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // use camera
    @IBAction func cameraBtnTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        imagePickerController.sourceType = .camera
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // select image
    @IBAction func selectBtnTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // save image
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        
    }
    
    //the func is called after you take a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //imagePickerController.dismiss(animated: true, completion: nil)
        
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!) {
            self.selectedImage = ciImage
        }
        
        //.. add code in another func
        recognizeImage(image: selectedImage)
    }
    
    //detection the picture
    func recognizeImage(image: CIImage) {
        
        resultLabel.text = "Detecting scene now..."
        //initilize the model
        /*
        if let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) {
            //an image analysis request that uses a Core ML model to process images
            let request = VNCoreMLRequest(model: model, completionHandler: { (vnreqest, error) in
                if let results = vnrequest.results as? [VNClassificationObservation]{
                    
                }
                
            })//end of request initilization
        }*/
        if let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) {
            let request = VNCoreMLRequest(model: model, completionHandler: { (vnrequest, error) in
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    let topResult = results.first
                    DispatchQueue.main.async {
                        let confidenceRate = (topResult?.confidence)! * 100
                        let rounded = Int (confidenceRate * 100) / 100
                        self.resultLabel.text = "\(rounded)% it's \(topResult?.identifier ?? "Unknown")"
                        self.resultLabel.text = "It's \(topResult?.identifier ?? "Unknown")"
                    }
                }
            })
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("Err :(")
                }
            }
        }
    }
    
}

