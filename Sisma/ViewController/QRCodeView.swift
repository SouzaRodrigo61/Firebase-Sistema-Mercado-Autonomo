//
//  QRCodeView.swift
//  Sisma
//
//  Created by Rodrigo Santos on 07/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class QRCodeView: UIViewController, QRCodeReaderViewControllerDelegate{
    
    @IBOutlet weak var previewView: QRCodeReaderView!{
        didSet {
            previewView.setupComponents(showCancelButton: false, showSwitchCameraButton: false, showTorchButton: false, showOverlayView: true, reader: reader)
        }
    }
    
    @IBOutlet weak var labelViewCollection: UILabel!
    var stringLabelView: String = ""
    
    var tempProdutos: Array<Produtos> = []
    
    @IBAction func scanInPreviewAction(_ sender: Any) {
        
        guard checkScanPermissions(), !reader.isRunning else { return }
        
        reader.didFindCode = { result in
            print("Completion with result: \(result.value) of type \(result.metadataType)")
            let alert = UIAlertController(
                title: "Produto Selecionado",
                message: String (format:"%@ (of type %@)", result.value),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.jsonDecoder(result.value)
        }
        
        reader.startScanning()
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
    
    // MARK: - Actions
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension QRCodeView{
    
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
            if let identification = dictionary["identification"] as? String{
                print("Identification: ",identification)
                DAO().adicionaDados(docData: (jsonObject as? [String: Any])!, data: "dadosProdutos", document: identification)
            }
        }
        
        
    }
    
}
