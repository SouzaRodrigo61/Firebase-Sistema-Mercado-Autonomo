//
//  CarrinhoCompras.swift
//  Sisma
//
//  Created by Rodrigo Santos on 13/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import AVFoundation
import Foundation
import Firebase
import UIKit

class CarrinhoCompras: UIViewController, QRCodeReaderViewControllerDelegate {
    
    fileprivate let PAYMENT_VIEW_SEGUE_IDENTIFIER = "PaymentView"
    fileprivate let DATA_DOCUMENT_FIRESTORE = "COMPRAS"
    
    var appList: Array<Dictionary<String, Any>> = []
    var produtos : [Produtos] = []
    var precoProdutos : Int = 0;
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func paymentActionButton(_ sender: Any) {
        
        let now = NSDate()
        let nowTimeStamp = getCurrentTimeStamp(now)
        
        let user = Auth.auth().currentUser
        
        if let user = user{
            let uid = user.uid
            
            let data = (DATA_DOCUMENT_FIRESTORE + "_" + uid + "_" + nowTimeStamp)
            
            for produto in appList {
                DAO().adicionaDados(docData: produto, data: data, document: (produto["title"] as? String)!)
            }
            
            performSegue(withIdentifier: PAYMENT_VIEW_SEGUE_IDENTIFIER, sender: appList)
        }
    }
    
    func getCurrentTimeStamp(_ date: NSDate) -> String{
        
        let objDateFormat : DateFormatter = DateFormatter()
        objDateFormat.dateFormat = "dd-MM-yyyy"
        let strTime: String = objDateFormat.string(from: date as Date)
        let objUTCDate: NSDate = objDateFormat.date(from: strTime)! as NSDate
        let milleSecond: Int64 = Int64(objUTCDate.timeIntervalSince1970)
        let timeStamp: String = "\(milleSecond)"
        return timeStamp
    }
    
    
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader          = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton = true
            
            $0.reader.stopScanningWhenCodeIsFound = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        getQueryOffLineNoWhereCase(data: "CarrinhoCompras", document: "compras")
        
        self.tableView.estimatedRowHeight = 84
        self.tableView.register(CarrinhoComprasCell.self, forCellReuseIdentifier: "cell")
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        
//        let path = Bundle.main.path(forResource: "appList", ofType: "plist")
//        appList = NSArray(contentsOfFile: path!) as? Array<Dictionary<String, Any>>
//        for _ in 1..<5 { appList.append(contentsOf: appList) }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @objc func showDetails(recognizer: UILongPressGestureRecognizer) {
//        if(recognizer.state == UIGestureRecognizerState.began) {
//            let cell = recognizer.view as! UITableViewCell
//
//            if let indexPath = tableView.indexPath(for: cell) {
//                let row = indexPath.row
//                let produto = appList[row]
//
//                RemoveMealController(controller: self).show(produto, handler : { action in
//                    self.produtos.remove(at: row)
//                    self.tableView.reloadData()
//                })
//            }
//        }
//    }
    
    @IBAction func QRCodeAction(_ sender: Any) {
        guard checkScanPermissions() else { return }
        
        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate               = self
        
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let result = result {
                print("Completion with result: \(result.value) of type \(result.metadataType)")
                self.jsonDecoder(result.value)
            }
        }
        
        present(readerVC, animated: true, completion: nil)
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
                    self.appList.append(dictionary)
                }
                
                let source = snapshot.metadata.isFromCache ? "local cache" : "server"
                print("Metadata: Data fetched from \(source)")
                
                self.tableView.reloadData()
        }
    }
}

extension CarrinhoCompras: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CarrinhoComprasCell
        let app = self.appList[indexPath.row]
        cell.update(app: app, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension CarrinhoCompras {
    
    // Mark: - Actions of decoder json
    
    func jsonDecoder(_ result: String) {
        let jsonString = result
        let jsonData = jsonString.data(using: String.Encoding.utf8)!
        let jsonObject = try! JSONSerialization.jsonObject(with: jsonData, options: [])
        let prettyJsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        let json = NSString(data: prettyJsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        print("JsonObject: ", jsonObject)
        print("prettyJsonData: ", prettyJsonData)
        print("json: ", json)
        
        if let dictionary = jsonObject as? [String: Any]{
            if let identification = dictionary["title"] as? String{
                print("Identification: ",identification)
                
                precoProdutos += (dictionary["price"] as? Int)!
                print("Preço de produtos: ", precoProdutos)
                
                self.appList.append(dictionary)
                self.tableView.reloadData()
                
//                DAO().adicionaDados(docData: (jsonObject as? [String: Any])!, data: "CarrinhoCompras", document: identification)
            }
        }
    }
    
    // MARK: - Actions of QRCodeReader
    
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            
            present(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
    // MARK: - QRCodeReader Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true) {}
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("Switching capturing to: \(newCaptureDevice.device.localizedName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
}
