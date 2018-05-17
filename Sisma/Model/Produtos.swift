//
//  ListaProdutos.swift
//  Sisma
//
//  Created by Rodrigo Santos on 08/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation
import UIKit

class Produtos {
    
    var imageView: UIImage
    var title: String
    var textBody: String
    
    init (image: UIImage, title: String, textBody: String){
        self.imageView = image
        self.title = title
        self.textBody = textBody
    }
}
