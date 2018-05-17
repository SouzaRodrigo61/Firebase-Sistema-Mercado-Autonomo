//
//  tableViewCell.swift
//  Sisma
//
//  Created by Rodrigo Santos on 08/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell{
    
    
    @IBOutlet weak var produtosImageView: UIImageView!
    @IBOutlet weak var titleLabelView: UILabel!
    @IBOutlet weak var textLabelView: UILabel!
    
    
    
    func setProduto(_ produto: Produtos){
        produtosImageView.image = produto.imageView
        titleLabelView.text = produto.title
        textLabelView.text = produto.textBody
    }
    
}
