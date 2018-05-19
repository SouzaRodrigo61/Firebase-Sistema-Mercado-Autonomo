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
    var tempProdutos: [Produtos] = []

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
    
    func getQueryOffLineNoWhereCase(data: String, document: String) -> [Produtos] {
        // Listen to metadata updates to receive a server snapshot even if
        // the data is the same as the cached data.
        
        let query = db.collection(data)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error retreiving snapshot: \(error!)")
                    return
                }
                
                for diff in snapshot.documentChanges {
                    let dictionary = diff.document.data()
                    
                    let title = dictionary["title"] as? String
                    let textBody = dictionary["textBody"] as? String
                    self.tempProdutos.append(Produtos(image: #imageLiteral(resourceName: "hawaiiResort"), title: title!, textBody: textBody!))
                    
                }
                
                print("Produtos: ", self.tempProdutos)
                
                let source = snapshot.metadata.isFromCache ? "local cache" : "server"
                print("Metadata: Data fetched from \(source)")
        }
        
        
        
        print("Query: ", query.description)
        print("tempProdutos: ", self.tempProdutos)
        
        return self.tempProdutos
        
    }
    
    fileprivate func baseQuery(data: String) -> Query {
        return db.collection(data)
    }
}
