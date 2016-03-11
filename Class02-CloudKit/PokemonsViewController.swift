//
//  ViewController.swift
//  Class02-CloudKit
//
//  Created by Henrique Valcanaia on 3/8/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

import CloudKit
import UIKit

class PokemonsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var pokemons = [Pokemon]()
    
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        refreshControl.addTarget(self, action: "loadData", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        collectionView.addSubview(refreshControl)
        
        
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { (status:CKAccountStatus, error:NSError?) in
            print(status.rawValue)
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
        DataManager.sharedInstance.sendLocalToRemoteWithBlock { (error:NSError?) in
            if error == nil {
                print("Upload finished")
                DataManager.sharedInstance.loadRemoteDataWithBlock({ (pokemons:[Pokemon]?, error:ErrorType?) in
                    if error == nil{
                        self.pokemons = pokemons!
                        dispatch_async(dispatch_get_main_queue()){
                            self.collectionView.reloadData()
                        }
                    } else {
                        print(error)
                    }
                })
                
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
            if error == nil {
                self.pokemons.removeAll()
                self.pokemons = pokemons!.sort { (p1, p2) -> Bool in
                    return p1.name.compare(p2.name) == NSComparisonResult.OrderedAscending
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView.reloadData()
                    if self.refreshControl.refreshing {
                        self.refreshControl.endRefreshing()
                    }
                }
            } else {
                print(error)
            }
        }
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
    
}

// MARK: - UICollectionViewDelegate
extension PokemonsViewController: UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
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