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
import ViewAnimator

class ProdutoListaView: UIViewController{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
    }
    
    @IBAction func animate() {
        // Combined animations example
        let fromAnimation = AnimationType.from(direction: .right, offset: 30.0)
        let zoomAnimation = AnimationType.zoom(scale: 0.2)
        let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/6)
        UIView.animate(views: collectionView.visibleCells,
                       animations: [zoomAnimation, rotateAnimation],
                       duration: 0.5)
        
        UIView.animate(views: tableView.visibleCells,
                       animations: [fromAnimation, zoomAnimation], delay: 0.5)
    }
}

extension ProdutoListaView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableViewCell
        cell.userImageView.image = UIImage(named: "\(indexPath.row)")
        return cell
    }
}

extension ProdutoListaView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.red
        cell.layer.cornerRadius = 5.0
//        cell.imageView.image = UIImage(named: "\(indexPath.item)")
        return cell
    }
}
