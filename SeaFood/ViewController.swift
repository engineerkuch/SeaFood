//
//  ViewController.swift
//  SeaFood
//
//  Created by Kelvin KUCH on 19.01.2023.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("[!] Error: Couldn't convert UIImage into a CIImage.")
            }
            
            detect(image: ciimage)
            
        } else {
            print("[!] userPickedImage error.")
        }
        
        imagePicker.dismiss(animated: true)
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("[!] Error: loading CoreML Model failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("[!] Error: VNClassificationObservation request cannot be completed.")
            }
            
            print("results: \(results).\nresults.hashValue:\(results.hashValue)n")
            print("results.capacity: \(results.capacity).\n=====")
            
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("seafood") {
                    self.navigationItem.title = "[+] seafood detected ;-)"
                } else {
                    self.navigationItem.title = "[-] no seafood detected :-|"
                }
            }
        }
        
        let ciihandler = VNImageRequestHandler(ciImage: image)
        
        do {
            try ciihandler.perform([request])
        } catch {
            print("[!] Error: \(error).")
        }
        
    }
}

