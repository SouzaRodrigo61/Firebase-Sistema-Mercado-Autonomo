//
//  Carrinho.swift
//  Sisma
//
//  Created by Rodrigo Santos on 13/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation
import UIKit

class Carrinho {
    
    var iconView: UIImageView!
    var actionButton: UIButton!
    var indexLabel, titleLabel, categoryLabel: UILabel!
    var ratingLabel, countLabel, iapLabel: UILabel!
    
    init (app: Dictionary<String, Any>, index: Int) {
        indexLabel.str(index + 1)
        iconView.img(app["iconName"] as! String)
        titleLabel.text = app["title"] as? String
        categoryLabel.text = app["category"] as? String
        countLabel.text = Str("(%@)", app["commentCount"] as! NSNumber)
        iapLabel.isHidden = !(app["iap"] as! Bool)
        
        let rating = (app["rating"] as! NSNumber).intValue
        var result = ""
        for i in 0..<5 { result = result + (i < rating ? "★" : "☆") }
        ratingLabel.text = result
        
        let price = app["price"] as! String
        actionButton.str( price.count > 0 ? "$" + price : "GET")
    }
}
