//
//  PokemonCell.swift
//  Class02-CloudKit
//
//  Created by Henrique Valcanaia on 3/8/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

import UIKit

protocol PokemonCellDelegate: class {
    func favoritePokemonInCell(cell:PokemonCell)
    func deletePokemonInCell(cell:PokemonCell)
}

class PokemonCell: UICollectionViewCell {
    
    @IBOutlet weak var pokemonImage: AsyncImageView!
    @IBOutlet weak var pokemonLabel: UILabel!
    @IBOutlet weak var star: UIImageView!
    weak var delegate:PokemonCellDelegate?
    
    override func awakeFromNib() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "favoriteTouched")
        gestureRecognizer.numberOfTapsRequired = 1
        star.addGestureRecognizer(gestureRecognizer)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "deletePokemon:")
        longPress.minimumPressDuration = 1.0
        self.addGestureRecognizer(longPress)
    }
    
    func configureCellWithPokemon(pokemon:Pokemon) {
        pokemonImage.image = nil
        pokemonImage.imageURL = NSURL(string: pokemon.image)
        pokemonLabel.text = pokemon.name
        
        let imageName = pokemon.isFavorite ? "starFilled" : "star"
        star.image = UIImage(named: imageName)
    }
    
    @objc func favoriteTouched() {
        delegate?.favoritePokemonInCell(self)
    }
    
    @objc func deletePokemon(longPress:UILongPressGestureRecognizer) {
        if longPress.state == .Began {
            delegate?.deletePokemonInCell(self)
        }
    }
    
}
