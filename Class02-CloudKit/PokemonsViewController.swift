//
//  ViewController.swift
//  Class02-CloudKit
//
//  Created by Henrique Valcanaia on 3/8/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

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
        
        loadData()
    }
    
    @objc private func loadData() {
        let dataManager = DataManager.sharedInstance
        
        dataManager.loadRemoteDataWithBlock { [unowned self] (pokemons:[Pokemon]?, error: ErrorType?) -> Void in
            if error == nil {
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
                print(error!)
            }
        }
        //
        //        dataManager.loadLocalDataWithBlock { [unowned self] (pokemons:[Pokemon]?, error:DataManagerError.LoadLocalData?) -> Void in
        //            if error == nil {
        //                self.pokemons = pokemons!
        //                self.collectionView.reloadData()
        //                if self.refreshControl.refreshing {
        //                    self.refreshControl.endRefreshing()
        //                }
        //            } else {
        //                switch error! {
        //                case .Error(let str):
        //                    print(str)
        //
        //                case .FileNotFound:
        //                    print("File not found")
        //
        //                case .ParseFileError:
        //                    print("erro parseando o arquivo")
        //                }
        //            }
        //        }
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
        
        return cell
    }
    
}