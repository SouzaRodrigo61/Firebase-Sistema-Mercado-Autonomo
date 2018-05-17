//
//  jsonDecoder.swift
//  Sisma
//
//  Created by Rodrigo Santos on 09/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation


class JsonDecoder{
    
    let jsonObject: Any
    let prettyJsonData: Any
    let Json: NSString
    
    public func decoderJson(_ jsonString: String){
        let jsonString = result.value
        let jsonData = jsonString.data(using: String.Encoding.utf8)!
        jsonObject = try! JSONSerialization.jsonObject(with: jsonData, options: [])
        let prettyJsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        let json = NSString(data: prettyJsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        
        print("JsonObject: ", jsonObject)
        print("prettyJsonData: ", prettyJsonData)
        print("json: ", json)
    }
    
    
}
