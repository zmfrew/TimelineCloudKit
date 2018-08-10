//
//  AddPostTableViewController.swift
//  Timeline
//
//  Created by Zachary Frew on 8/7/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var captionText: UITextField!
    
    // MARK: - Instance Properties
    var image: UIImage?
    
    // MARK: - Actions
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        guard let image = image,
            let text = captionText.text, !text.isEmpty, text != " " else {
                presentAlertController()
                return
        }
        
        PostController.shared.createPostWith(image: image, andCaption: text) { (_) in
            guard let tbController = self.navigationController?.parent as? UITabBarController else { return }
            DispatchQueue.main.async {
                self.resignFirstResponder()
                tbController.selectedIndex = 0
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        guard let tbController = self.navigationController?.parent as? UITabBarController else { return }
        DispatchQueue.main.async {
            tbController.selectedIndex = 0
        }
    }
    
    // MARK: - Instance Methods
    func presentAlertController() {
        let alertController = UIAlertController(title: "Oops!", message: "Please ensure you have an image and a caption before posting!", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoSelector" {
            let destinationVC = segue.destination as? PhotoSelectViewController
            destinationVC?.delegate = self
        }
    }
  
}

extension AddPostTableViewController: PhotoSelectViewControllerDelegate {
    
    func photoSelectViewControllerSelected(image: UIImage) {
        self.image = image
    }
    
}
