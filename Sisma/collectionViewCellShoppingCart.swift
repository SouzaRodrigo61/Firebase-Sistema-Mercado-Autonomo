//
//  collectionViewCellShoppingCart.swift
//  Sisma
//
//  Created by Rodrigo Santos on 07/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation
import UIKit

class collectionViewCellShoppingCart: UICollectionViewCell{

    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var labelViewCell: UILabel!
    
    func displayContent(image: UIImage, title: String) {
        imageViewCell.image = image
        labelViewCell.text = title
    }
    
}
