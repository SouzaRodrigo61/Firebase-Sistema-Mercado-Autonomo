//
//  RoundButton.swift
//  Sisma
//
//  Created by Rodrigo Santos on 05/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation
import UIKit

class RoundButton: UIButton {
    override func awakeFromNib() {
        super .awakeFromNib()
        
        layer.borderWidth = 2/UIScreen.main.nativeScale
        layer.borderColor = UIColor.black.cgColor
    }
    
    override func layoutSubviews() {
        super .layoutSubviews()
        
        layer.cornerRadius = frame.height/2
        layer.borderColor = UIColor.black.cgColor
    }
}
