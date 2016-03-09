//
//  PokemonCell.swift
//  Class02-CloudKit
//
//  Created by Henrique Valcanaia on 3/8/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

import UIKit

class PokemonCell: UICollectionViewCell {
    
    @IBOutlet weak var pokemonImage: AsyncImageView!
    @IBOutlet weak var pokemonLabel: UILabel!
    @IBOutlet weak var health: UIProgressView!
    @IBOutlet weak var attack: UIProgressView!
    @IBOutlet weak var defense: UIProgressView!
    
    func configureCellWithPokemon(pokemon:Pokemon) {
        pokemonImage.imageURL = NSURL(string: pokemon.image)
        pokemonLabel.text = pokemon.name
        
        self.health.progress = 0
        self.attack.progress = 0
        self.defense.progress = 0
        
        UIView.animateWithDuration(0.3) { [unowned self] in
            let healthProgress = Float(pokemon.status.health * 100 / DataManager.sharedInstance.higherHealth) / 100
            let attackProgress = Float(pokemon.status.attack * 100 / DataManager.sharedInstance.higherAttack) / 100
            let defenseProgress = Float(pokemon.status.defense * 100 / DataManager.sharedInstance.higherDefense) / 100
            
            self.health.setProgress(healthProgress, animated: true)
            self.health.tintColor = self.progressColorWithValue(healthProgress)
            
            self.attack.setProgress(attackProgress, animated: true)
            self.attack.tintColor = self.progressColorWithValue(attackProgress)
            
            self.defense.setProgress(defenseProgress, animated: true)
            self.defense.tintColor = self.progressColorWithValue(defenseProgress)
        }
    }
    
    private func progressColorWithValue(value:Float) -> UIColor{
        if value >= 0 && value < 1/3 {
            return UIColor ( red: 0.6067, green: 0.0, blue: 0.0, alpha: 1.0 )
        } else if value >= 1/3 && value < (1/3)*2 {
            return UIColor ( red: 0.8714, green: 0.8712, blue: 0.0, alpha: 1.0 )
        } else {
            return UIColor ( red: 0.0, green: 0.7157, blue: 0.0002, alpha: 1.0 )
        }
    }
}
