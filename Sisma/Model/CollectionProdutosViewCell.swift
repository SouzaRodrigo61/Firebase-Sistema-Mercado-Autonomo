//
//  CollectionProdutosViewCell.swift
//  Sisma
//
//  Created by Rodrigo Santos on 12/06/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation
import UIKit

class CollectionProdutosViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView.superview == nil {
            imageView.frame = bounds
            imageView.layer.cornerRadius = layer.cornerRadius
            addSubview(imageView)
        }
    }
}
