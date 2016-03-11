//
//  AddStatusViewController.swift
//  Class02-CloudKit
//
//  Created by Henrique Valcanaia on 3/11/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

import CloudKit
import SVProgressHUD
import UIKit

class AddStatusViewController: UIViewController {
    
    @IBOutlet weak var healthTextField: UITextField!
    @IBOutlet weak var attackTextField: UITextField!
    @IBOutlet weak var defenseTextField: UITextField!
    @IBOutlet weak var spAttackTextField: UITextField!
    @IBOutlet weak var spDefenseTextField: UITextField!
    @IBOutlet weak var speedTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    private let GoToAddSkillSegue = "gotoAddSkill"
    var pokemon:Pokemon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func nextTapped(sender: AnyObject) {
        self.performSegueWithIdentifier(GoToAddSkillSegue, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == GoToAddSkillSegue {
            let status = Status()
            status.health = Int(healthTextField.text!)!
            status.attack = Int(attackTextField.text!)!
            status.defense = Int(defenseTextField.text!)!
            status.spAttack = Int(spAttackTextField.text!)!
            status.spDefense = Int(spDefenseTextField.text!)!
            status.speed = Int(speedTextField.text!)!
            pokemon.status = status
            
            let vc = segue.destinationViewController as! AddSkillViewController
            vc.pokemon = pokemon
        }
    }
}
