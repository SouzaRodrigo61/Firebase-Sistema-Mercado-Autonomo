//
//  jsonStruct.swift
//  Sisma
//
//  Created by Rodrigo Santos on 09/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation
import UIKit

struct Mercado{
    enum Categoria: String {
        case alimento, bebidas, carne, frios,
            laticinios, frutas, verduras, legumes,
            higiene, limpeza, padaria, outros
    }
    
    let title: String
    let textBody: String
    let preco: Double
    let imageID: int
    let categoria: Set<Categoria>
}

extension Mercado{
    
    init(json: [String: Any]) {
        guard let text = json["text"],
            let textBody = json["textBody"],
            let preco = json["preco"],
            let imageID = json["imageID"],
            let categoria = json["categoria"] as? [String]
        else { return nil }
    }
    
    
}
