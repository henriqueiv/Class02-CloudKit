//
//  AddPokemonViewController.swift
//  Class02-CloudKit
//
//  Created by Henrique Valcanaia on 3/11/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

import CloudKit
import UIKit

class AddPokemonViewController: UIViewController {
    
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var levelTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var type1TextField: UITextField!
    @IBOutlet weak var type2TextField: UITextField!
    @IBOutlet weak var favoriteImageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var isFavorite = false
    private let GoToStatusSegue = "gotoAddStatus"
    private var keyboardHeight:CGFloat!
    private var destinationImageView:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "favoriteTouched")
        gestureRecognizer.numberOfTapsRequired = 1
        favoriteImageView.addGestureRecognizer(gestureRecognizer)
        
        let tapPokemonImageRecognizer = UITapGestureRecognizer(target: self, action: "didTouchPokemonImageView")
        tapPokemonImageRecognizer.numberOfTapsRequired = 1
        pokemonImageView.addGestureRecognizer(tapPokemonImageRecognizer)
        
        let tapIconImageRecognizer = UITapGestureRecognizer(target: self, action: "didTouchIconImageView")
        tapIconImageRecognizer.numberOfTapsRequired = 1
        iconImageView.addGestureRecognizer(tapIconImageRecognizer)
        
        scrollView.keyboardDismissMode = .Interactive
        setupKeyboardControls()
    }
    
    private func setupKeyboardControls() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowOrHide:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowOrHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "viewTapped")
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Private helpers
    func keyboardWillShowOrHide(notification: NSNotification) {
        
        // Pull a bunch of info out of the notification
        if let scrollView = scrollView, userInfo = notification.userInfo, endValue = userInfo[UIKeyboardFrameEndUserInfoKey], durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey], curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey] {
            
            // Transform the keyboard's frame into our view's coordinate system
            let endRect = view.convertRect(endValue.CGRectValue, fromView: view.window)
            
            // Find out how much the keyboard overlaps the scroll view
            // We can do this because our scroll view's frame is already in our view's coordinate system
            let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y
            
            // Set the scroll view's content inset to avoid the keyboard
            // Don't forget the scroll indicator too!
            scrollView.contentInset.bottom = keyboardOverlap
            scrollView.scrollIndicatorInsets.bottom = keyboardOverlap
            
            let duration = durationValue.doubleValue
            let options = UIViewAnimationOptions(rawValue: UInt(curveValue.integerValue << 16))
            UIView.animateWithDuration(duration, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    @objc private func viewTapped() {
        self.view.endEditing(true)
    }
    
    @objc private func favoriteTouched() {
        isFavorite = !isFavorite
        let imageName = isFavorite ? "starFilled" : "star"
        let image = UIImage(named: imageName)
        favoriteImageView.image = image
    }
    
    @IBAction func nextTapped(sender: AnyObject) {
        self.performSegueWithIdentifier(GoToStatusSegue, sender: nil)
    }
    
    private func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == GoToStatusSegue{
            let pokemon = Pokemon()
            pokemon.number = Int(numberTextField.text!)!
            pokemon.name = nameTextField.text!
            
            if let image = pokemonImageView.image {
                if let data = UIImagePNGRepresentation(image) {
                    let filename = getDocumentsDirectory().stringByAppendingPathComponent(Pokemon.ImageName)
                    data.writeToFile(filename, atomically: true)
                    pokemon.icon = filename
                }
            }
            
            if let image = iconImageView.image {
                if let data = UIImagePNGRepresentation(image) {
                    let filename = getDocumentsDirectory().stringByAppendingPathComponent(Pokemon.IconName)
                    data.writeToFile(filename, atomically: true)
                    pokemon.icon = filename
                }
            }
            
            pokemon.level = Int(levelTextField.text!)!
            pokemon.type1 = type1TextField.text!
            pokemon.type2 = type2TextField.text!
            pokemon.isFavorite = isFavorite
            
            let vc = segue.destinationViewController as! AddStatusViewController
            vc.pokemon = pokemon
        }
    }
    
    @objc private func didTouchPokemonImageView() {
        destinationImageView = pokemonImageView
        didTouchImageView()
    }
    
    @objc private func didTouchIconImageView() {
        destinationImageView = iconImageView
        didTouchImageView()
    }
    
    private func didTouchImageView() {
        let imgController = UIImagePickerController()
        imgController.delegate = self
        imgController.allowsEditing = true
        imgController.sourceType = .PhotoLibrary
        
        presentViewController(imgController, animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerController
extension AddPokemonViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        destinationImageView.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
}