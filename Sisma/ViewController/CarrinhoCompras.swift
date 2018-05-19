//
//  CarrinhoCompras.swift
//  Sisma
//
//  Created by Rodrigo Santos on 13/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import AVFoundation
import StatusAlert
import Foundation
import Firebase
import UIKit
import Stripe

class CarrinhoCompras: UIViewController,QRCodeReaderViewControllerDelegate {
    
    fileprivate let PAYMENT_VIEW_SEGUE_IDENTIFIER = "PaymentView"
    fileprivate let DATA_DOCUMENT_FIRESTORE = "COMPRAS"
    
    private let customerContext: STPCustomerContext
    private let paymentContext: STPPaymentContext
    
    @IBOutlet var paymentButton: UIButton!
    @IBOutlet var priceButton: UIButton!
    
    @IBAction func paymentButton(_ sender: Any) {
        let now = NSDate()
        let nowTimeStamp = getCurrentTimeStamp(now)
        
        let user = Auth.auth().currentUser
        
        if let user = user{
            let uid = user.uid
            
            let data = (DATA_DOCUMENT_FIRESTORE + "_" + uid + "_" + nowTimeStamp)
            
            for produto in appList {
                DAO().adicionaDados(docData: produto, data: data, document: (produto["title"] as? String)!)
            }
            
            //            performSegue(withIdentifier: PAYMENT_VIEW_SEGUE_IDENTIFIER, sender: appList)
            presentPaymentMethodsViewController()
            //            statusAlert.showInKeyWindow()
        }
    }
    @IBAction func priceButton(_ sender: Any) {
        let now = NSDate()
        let nowTimeStamp = getCurrentTimeStamp(now)
        
        let user = Auth.auth().currentUser
        
        if let user = user{
            let uid = user.uid
            
            let data = (DATA_DOCUMENT_FIRESTORE + "_" + uid + "_" + nowTimeStamp)
            
            for produto in appList {
                DAO().adicionaDados(docData: produto, data: data, document: (produto["title"] as? String)!)
            }
            
            //            performSegue(withIdentifier: PAYMENT_VIEW_SEGUE_IDENTIFIER, sender: appList)
            presentPaymentMethodsViewController()
            //            statusAlert.showInKeyWindow()
        }
    }
    
    let statusAlert = StatusAlert.instantiate(
        withImage: UIImage(named: "Some image name"),
        title: "StatusAlert title",
        message: "Message to show beyond title",
        canBePickedOrDismissed: true)
    
    var appList: Array<Dictionary<String, Any>> = []
    var produtos : [Produtos] = []
    var precoProdutos : Int = 0;
    
    private var price = 0 {
        didSet {
            // Forward value to payment context
            paymentContext.paymentAmount = price
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func paymentActionButton(_ sender: Any) {
        statusAlert.showInKeyWindow()
        
    }
    
    private func presentPaymentMethodsViewController() {
        guard !STPPaymentConfiguration.shared().publishableKey.isEmpty else {
            // Present error immediately because publishable key needs to be set
            let message = "Please assign a value to `publishableKey` before continuing. See `AppDelegate.swift`."
            present(UIAlertController(message: message), animated: true)
            return
        }
        
        guard !PaymentAPIClient.shared.baseURLString.isEmpty else {
            // Present error immediately because base url needs to be set
            let message = "Please assign a value to `PaymentAPIClient.shared.baseURLString` before continuing. See `AppDelegate.swift`."
            present(UIAlertController(message: message), animated: true)
            return
        }
        
        // Present the Stripe payment methods view controller to enter payment details
        paymentContext.presentPaymentMethodsViewController()
    }
    
    private func reloadPaymentButtonContent() {
        guard let selectedPaymentMethod = paymentContext.selectedPaymentMethod else {
            // Show default image, text, and color
            paymentButton.setImage(#imageLiteral(resourceName: "Payment"), for: .normal)
            paymentButton.setTitle("Payment", for: .normal)
            paymentButton.setTitleColor(.riderGrayColor, for: .normal)
            return
        }
        
        // Show selected payment method image, label, and darker color
        paymentButton.setImage(selectedPaymentMethod.image, for: .normal)
        paymentButton.setTitle(selectedPaymentMethod.label, for: .normal)
        paymentButton.setTitleColor(.riderDarkBlueColor, for: .normal)
    }
    
    private func reloadPriceButtonContent() {
        price = precoProdutos
        
        // Show formatted price text and darker color
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        priceFormatter.locale = Locale(identifier: "en_US")
        
        let priceString = priceFormatter.string(for: price)
        priceButton.setTitle(priceString, for: .normal)
        priceButton.setTitleColor(.riderDarkBlueColor, for: .normal)
    }
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        customerContext = STPCustomerContext(keyProvider: PaymentAPIClient.shared)
        paymentContext = STPPaymentContext(customerContext: customerContext)
        
        super.init(coder: aDecoder)
        
        paymentContext.delegate = self
        paymentContext.hostViewController = self
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
        
        db.collection(data)
            .addSnapshotListener { querySnapshot, error in
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
                self.reloadPriceButtonContent()
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

extension CarrinhoCompras: STPPaymentContextDelegate{
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        self.reloadPaymentButtonContent()
        self.reloadPriceButtonContent()
    }
    
    public func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        if let customerKeyError = error as? PaymentAPIClient.CustomerKeyError {
            switch customerKeyError {
            case .missingBaseURL:
                // Fail silently until base url string is set
                print("[ERROR]: Please assign a value to `MainAPIClient.shared.baseURLString` before continuing. See `AppDelegate.swift`.")
            case .invalidResponse:
                // Use customer key specific error message
                print("[ERROR]: Missing or malformed response when attempting to `PaymentAPIClient.shared.createCustomerKey`. Please check internet connection and backend response formatting.");
                
                present(UIAlertController(message: "Could not retrieve customer information", retryHandler: { (action) in
                    // Retry payment context loading
                    paymentContext.retryLoading()
                }), animated: true)
            }
        }
        else {
            // Use generic error message
            print("[ERROR]: Unrecognized error while loading payment context: \(error)");
            
            present(UIAlertController(message: "Could not retrieve payment information", retryHandler: { (action) in
                // Retry payment context loading
                paymentContext.retryLoading()
            }), animated: true)
        }
    }
    
    public func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        switch status {
        case .success:
            // Animate active ride
//            animateActiveRide()
            print("Pagamento efetuado")
        case .error:
            // Present error to user
            if let requestRideError = error as? PaymentAPIClient.RequestRideError {
                switch requestRideError {
                case .missingBaseURL:
                    // Fail silently until base url string is set
                    print("[ERROR]: Please assign a value to `MainAPIClient.shared.baseURLString` before continuing. See `AppDelegate.swift`.")
                case .invalidResponse:
                    // Missing response from backend
                    print("[ERROR]: Missing or malformed response when attempting to `MainAPIClient.shared.requestRide`. Please check internet connection and backend response formatting.");
                    present(UIAlertController(message: "Could not request ride"), animated: true)
                }
            }
            else {
                // Use generic error message
                print("[ERROR]: Unrecognized error while finishing payment: \(String(describing: error))");
                present(UIAlertController(message: "Could not request ride"), animated: true)
            }
            
            // Reset ride request state
        case .userCancellation:
            // Reset ride request state
            print("Pagamento não efetuado")
        }
    }
    
    public func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        let source = paymentResult.source.stripeID
        
//        PaymentAPIClient.shared.requestRide(source: source, amount: price, currency: "usd") { [weak self] (ride, error) in
//            guard let strongSelf = self else {
//                // View controller was deallocated
//                return
//            }
//
//            guard error == nil else {
//                // Error while requesting ride
//                completion(error)
//                return
//            }
//
//            // Save ride info to display after payment finished
//            strongSelf.rideRequestState = .active(ride!)
//            completion(nil)
//        }
    }
    
    public func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        
    }
    
    
}
