//
//  DAO.swift
//  Sisma
//
//  Created by Rodrigo Santos on 09/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation
import Firebase

class DAO {
    
    let db = Firestore.firestore()
    let settings = FirestoreSettings()
    // Add a new document with a generated ID
    var ref: DocumentReference? = nil

    init() {
        settings.isPersistenceEnabled = true
        db.settings = settings
    }
    
    func adicionaDados(docData: [String: Any], data: String, document: String) {
        
        db.collection(data).document(document).setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    fileprivate func baseQuery(data: String) -> Query {
        return db.collection(data)
    }
}
