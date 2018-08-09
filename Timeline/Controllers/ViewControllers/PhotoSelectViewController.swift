//
//  PhotoSelectViewController.swift
//  Timeline
//
//  Created by Zachary Frew on 8/8/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit

protocol PhotoSelectViewControllerDelegate: class {
    func photoSelectViewControllerSelected(image: UIImage)
}

class PhotoSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    // MARK: - Outlets
    @IBOutlet weak var postIV: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    // MARK: - Instance Properties
    weak var delegate: PhotoSelectViewControllerDelegate?

    @IBAction func selectImageButtonTapped(_ sender: Any) {
        selectImageButton.setTitle("", for: .normal)
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let alertController = UIAlertController(title: "Choose the photo location.", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(UIAlertAction(title: "Photo Library", style: .default) { (_) in
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }))
        }
        
        selectImageButton.setTitle("Select Image", for: UIControlState())
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            delegate?.photoSelectViewControllerSelected(image: image)
            selectImageButton.setTitle("", for: UIControlState())
            postIV.image = image
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
