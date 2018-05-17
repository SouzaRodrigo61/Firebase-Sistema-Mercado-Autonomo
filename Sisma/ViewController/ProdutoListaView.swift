//
//  ProdutoListaView.swift
//  Sisma
//
//  Created by Rodrigo Santos on 08/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ProdutoListaView: UIViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    let locationNames = ["Hawaii Resort", "Mountain Expedition", "Scuba Diving"]
    
    let locationImages = [UIImage(named: "hawaiiResort"), UIImage(named: "mountainExpedition"), UIImage(named: "scubaDiving")]
    
    let locationDescription = ["Beautiful resort off the coast of Hawaii", "Exhilarating mountainous expedition through Yosemite National Park", "Awesome Scuba Diving adventure in the Gulf of Mexico"]
    
    
    var produtos: [Produtos] = []
    
    func createArray() -> [Produtos]{
        var tempProdutos: [Produtos] = []
        
        let produto0 = Produtos(image: #imageLiteral(resourceName: "scubaDiving"), title: "Maça", textBody: "Beautiful resort off the coast of Hawaii")
        let produto1 = Produtos(image: #imageLiteral(resourceName: "background"), title: "Maça", textBody: "Exhilarating mountainous expedition through Yosemite National Park")
        let produto2 = Produtos(image: #imageLiteral(resourceName: "mountainExpedition"), title: "Maça", textBody: "Awesome Scuba Diving adventure in the Gulf of Mexico")
        tempProdutos.append(produto0)
        tempProdutos.append(produto1)
        tempProdutos.append(produto2)
        
        return tempProdutos
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        getQueryOffLineNoWhereCase( data: "dadosProdutos", document: "produtos")
        
//        produtos = createArray()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getQueryOffLineNoWhereCase(data: String, document: String) {
        
        let db = Firestore.firestore()
        
        // Listen to metadata updates to receive a server snapshot even if
        // the data is the same as the cached data.
        let options = QueryListenOptions()
        options.includeQueryMetadataChanges(true)
        
        db.collection(data)
            .addSnapshotListener(options: options) { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error retreiving snapshot: \(error!)")
                    return
                }
                
                for diff in snapshot.documentChanges {
                    let dictionary = diff.document.data()
                    
                    let title = dictionary["title"] as? String
                    let textBody = dictionary["textBody"] as? String
                    self.produtos.append(Produtos(image: #imageLiteral(resourceName: "hawaiiResort"), title: title!, textBody: textBody!))
                    
                }
                
                let source = snapshot.metadata.isFromCache ? "local cache" : "server"
                print("Metadata: Data fetched from \(source)")
                
                self.collectionView.reloadData()
        }
    }

}

extension ProdutoListaView: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return produtos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let produto = produtos[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.setProduto(produto)
        
        //This creates the shadows and modifies the cards a little bit
        cell.contentView.layer.cornerRadius = 6.0
        cell.contentView.layer.borderWidth = 2.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 6.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius:
        cell.contentView.layer.cornerRadius).cgPath
        
        return cell
    }
}

