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
    weak var pokemon:Pokemon!
    
    func configureCellWithPokemon(pokemon:Pokemon) {
        pokemonImage.imageURL = NSURL(string: pokemon.image)
        pokemonLabel.text = pokemon.name
    }
}
