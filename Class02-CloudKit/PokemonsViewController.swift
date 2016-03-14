//
//  ViewController.swift
//  Class02-CloudKit
//
//  Created by Henrique Valcanaia on 3/8/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

import CloudKit
import SVProgressHUD
import UIKit

class PokemonsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var progressView: UIProgressView!
    
    private var pokemons = [Pokemon]()
    
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        refreshControl.addTarget(self, action: "loadData", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
        
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { (status:CKAccountStatus, error:NSError?) in
            if status == .NoAccount {
                let alert = UIAlertController(title: "Sign in to iCloud", message: "Sign in to your iCloud account to write records. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", preferredStyle: .Alert)
                
                alert.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated:true, completion:nil)
                
            } else {
                self.loadData()
            }
        }
    }
    
    @IBAction func uploadData(sender: AnyObject) {
        self.progressView.setProgress(0.0, animated: true)
        DataManager.sharedInstance.sendLocalToRemote({ (record:CKRecord?, progress:Float) in
            dispatch_async(dispatch_get_main_queue()){
                print(progress)
                self.progressView.setProgress(progress, animated: true)
            }
        }) { (error:NSError?) in
            if error == nil {
                print("foi")
                self.progressView.setProgress(1.0, animated: true)
            } else {
                print(error)
            }
        }
    }
    
    @IBAction func deleteData(sender: AnyObject) {
        Pokemon.deleteAllWithCompletionblock { (recordZoneID:CKRecordZoneID?, error:NSError?) in
            if error == nil {
                print("foi")
            } else {
                print(error)
            }
        }
    }
    
    @objc private func loadData() {
        let dataManager = DataManager.sharedInstance
        dataManager.loadRemoteDataWithBlock { [unowned self] (pokemons:[Pokemon]?, error: ErrorType?) -> Void in
            self.pokemons.removeAll()
            if error == nil {
                self.pokemons = pokemons!.sort { (p1, p2) -> Bool in
                    return p1.name.compare(p2.name) == NSComparisonResult.OrderedAscending
                }
            } else {
                print(error)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView.reloadData()
                if self.refreshControl.refreshing {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    @IBAction func backToPokemonsViewController(segue:UIStoryboardSegue) {
        
    }
    
}

// MARK - PokemonCellDelegate
extension PokemonsViewController: PokemonCellDelegate {
    
    func favoritePokemonInCell(cell: PokemonCell) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            let pokemon = pokemons[indexPath.row]
            pokemon.isFavorite = !pokemon.isFavorite
            pokemon.update()
            cell.configureCellWithPokemon(pokemons[indexPath.row])
        }
    }
    
    func deletePokemonInCell(cell: PokemonCell) {
        let alert = UIAlertController(title: "Delete pokemon", message: "Are u sure?", preferredStyle: .Alert)
        
        let yes = UIAlertAction(title: "Yes", style: .Destructive) { (action) in
            if let indexPath = self.collectionView.indexPathForCell(cell) {
                let pokemon = self.pokemons[indexPath.row]
                pokemon.deleteWithCompletionBlock({ (recordID:CKRecordID?, error:NSError?) in
                    print("deleted")
                    self.pokemons.removeAtIndex(indexPath.row)
                    dispatch_async(dispatch_get_main_queue()){
                        self.collectionView.reloadData()
                    }
                })
            }
        }
        alert.addAction(yes)
        
        let no = UIAlertAction(title: "No", style: .Cancel) { (action) in
            print("cancel")
        }
        alert.addAction(no)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionViewDelegate
extension PokemonsViewController: UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension PokemonsViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PokemonCell", forIndexPath: indexPath) as! PokemonCell
        
        cell.configureCellWithPokemon(pokemons[indexPath.row])
        cell.delegate = self
        
        return cell
    }
    
}