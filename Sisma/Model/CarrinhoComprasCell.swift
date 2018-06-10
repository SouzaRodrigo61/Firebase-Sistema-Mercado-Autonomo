//
//  CarrinhoComprasCell.swift
//  Sisma
//
//  Created by Rodrigo Santos on 13/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation
import UIKit

class CarrinhoComprasCell: UITableViewCell {
//    let items = ["-", "+"]
    var iconView: UIImageView!
//    var actionButton: UISegmentedControl!
    var indexLabel, titleLabel, categoryLabel: UILabel!
    var ratingLabel, countLabel, iapLabel: UILabel!
    
    func update(app: Dictionary<String, Any>, index: Int) {
        indexLabel.str(index + 1)
        iconView.img(app["iconName"] as! String)
        titleLabel.text = app["title"] as? String
        categoryLabel.text = app["category"] as? String
        countLabel.text = Str("(%@)", app["commentCount"] as! String)
        iapLabel.isHidden = !(app["iap"] as! Bool)
        
        let rating = (app["rating"] as! NSNumber).intValue
        var result = ""
        for i in 0..<5 { result = result + (i < rating ? "★" : "☆") }
        ratingLabel.text = result
        
        let price = app["price"] as! Int
//        actionButton.selectedSegmentIndex = 0
//        actionButton.str("Add")
        
        iapLabel.str("R$" + String(price))
    }
    
    func setupUI() {
        indexLabel = Label.font(17).color("darkGray").align(.center).pin(.w(44))
        iconView = ImageView.pin(64, 64).radius(10).border(1.0 / UIScreen.main.scale, "#CCC")
        
        titleLabel = Label.font(15).lines(0)
        categoryLabel = Label.font(13).color("darkGray")
        
        ratingLabel = Label.font(11).color("orange")
        countLabel = Label.font(11).color("darkGray")
        
//        actionButton = Button.font("15").color("#0065F7").border(1, "#0065F7").radius(3)
//        actionButton.highColor("white").highBg("#0065F7").padding(5, 10)
        
        iapLabel = Label.font(13).color("darkGray").lines(2).align(.center)
        
        let ratingStack = HStack(ratingLabel, countLabel).gap(5)
        let midStack = VStack(titleLabel, categoryLabel, ratingStack).gap(4)
        let actionStack = VStack(iapLabel).gap(4).align(.center)
        
        HStack(indexLabel, iconView, 10, midStack, "<-->", 10, actionStack).embedIn(self.contentView, 10, 0, 10, 15)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
