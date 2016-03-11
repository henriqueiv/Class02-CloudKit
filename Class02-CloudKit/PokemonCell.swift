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
    }
    
    func configureCellWithPokemon(pokemon:Pokemon) {
        pokemonImage.imageURL = NSURL(string: pokemon.image)
        pokemonLabel.text = pokemon.name
        
        let imageName = pokemon.isFavorite ? "starFilled" : "star"
        star.image = UIImage(named: imageName)
    }
    
    @objc func favoriteTouched() {
        delegate?.favoritePokemonInCell(self)
    }
    
}
