//
//  ViewController.swift
//  clever-image
//
//  Created by Mehmet Koca on 22/08/2017.
//  Copyright © 2017 on3. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    var selectedImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func selectBtnTapped(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!) {
            self.selectedImage = ciImage
        }
        
        recognizeImage(image: selectedImage)
    }
    
    func recognizeImage(image: CIImage) {
        
        resultLabel.text = "I'm investigating..."
        
        if let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) {
            let request = VNCoreMLRequest(model: model, completionHandler: { (vnrequest, error) in
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    let topResult = results.first
                    DispatchQueue.main.async {
                        let confidenceRate = (topResult?.confidence)! * 100
                        let rounded = Int (confidenceRate * 100) / 100
                        self.resultLabel.text = "\(rounded)% it's \(topResult?.identifier ?? "Anonymous")"
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

