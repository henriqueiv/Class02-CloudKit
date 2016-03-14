//
//  AddSkillViewController.swift
//  Class02-CloudKit
//
//  Created by Henrique Valcanaia on 3/11/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

import CloudKit
import UIKit

class AddSkillViewController: UIViewController {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var damageCategoryTextField: UITextField!
    @IBOutlet weak var powerTextField: UITextField!
    @IBOutlet weak var accuracyTextField: UITextField!
    @IBOutlet weak var powerPointTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var skills = [Skill]()
    var pokemon:Pokemon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    @IBAction func addSkillTapped(sender: AnyObject) {
        let skill = createSkill()
        skills += [skill]
        tableView.reloadData()
    }
    
    private func createSkill() -> Skill {
        let skill = Skill()
        skill.name = nameTextField.text!
        skill.type = typeTextField.text!
        skill.damageCategory = damageCategoryTextField.text!
        skill.power = Int(powerTextField.text!)!
        skill.accuracy = Int(accuracyTextField.text!)!
        skill.powerPoint = Int(powerPointTextField.text!)!
        
        return skill
    }
    
    @IBAction func doneTapped(sender: AnyObject) {
        pokemon.skills = skills
        
        var recordsToSave = [CKRecord]()
        recordsToSave += [pokemon.asCKRecord()]
        if pokemon.status != nil {
            recordsToSave += [pokemon.status!.asCKRecord()]
        }
        
        if pokemon.skills?.count > 0 {
            recordsToSave += pokemon.skills!.map({$0.asCKRecord()})
        }
        
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        var successCount = 0
        operation.perRecordCompletionBlock = { (record, error) in
            if error == nil {
                successCount += 1
                if recordsToSave.count == successCount {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                print(error)
            }
        }
        
        Database.Public.addOperation(operation)
    }
    
}

// MARK: - UITableViewDelegate
extension AddSkillViewController: UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
            self.skills.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
        })
        
        return [deleteAction]
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Skills"
    }
    
    
    
}

// MARK: - UITableViewDataSource
extension AddSkillViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skills.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier("SkillCell") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = skills[indexPath.row].name
        cell.detailTextLabel?.text = skills[indexPath.row].type
        
        return cell
    }
    
}