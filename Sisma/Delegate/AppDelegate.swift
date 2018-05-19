//
//  AppDelegate.swift
//  Sisma
//
//  Created by Rodrigo Santos on 05/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import Stripe
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    static var checkerFG : Int = 0
    private let locationManager: CLLocationManager = CLLocationManager()
    
    /**
     Fill in your Stripe publishable key here. This can be either your
     test or live publishable key. The key should begin with "pk_".
     
     You can find your publishable key in the Stripe Dashboard after you've
     signed up for an account.
     
     @see https://dashboard.stripe.com/account/apikeys
     
     If you'd like to use this app with https://rocketrides.io (see below),
     you can use our test publishable key: "pk_test_hnUZptHh36jRUveejCXqRoVu".
     */
    private let publishableKey: String = "pk_test_6SrhR3uGobyX9Qu5NRO9kZ8A"
    
    /**
     Fill in your backend URL here to try out the full payment experience
     
     Ex: "http://localhost:3000" if you're running the Node server locally,
     or "https://rocketrides.io" to try the app using our hosted version.
     */
    private let baseURLString: String = "https://rocketrides.io"
    
    /**
     Optionally, fill in your Apple Merchant identifier here to try out the
     Apple Pay payment experience. We can use the "merchant.xyz" placeholder
     here when testing in the iOS simulator.
     
     @see https://stripe.com/docs/apple-pay/apps
     */
    private let appleMerchantIdentifier: String = "merchant.xyz"
    
    override init() {
        super.init()
        
        // Stripe payment configuration
        STPPaymentConfiguration.shared().companyName = "Rocket Rides"
        
        if !publishableKey.isEmpty {
            STPPaymentConfiguration.shared().publishableKey = publishableKey
        }
        
        if !appleMerchantIdentifier.isEmpty {
            STPPaymentConfiguration.shared().appleMerchantIdentifier = appleMerchantIdentifier
        }
        
        // Stripe theme configuration
        STPTheme.default().primaryBackgroundColor = .riderVeryLightGrayColor
        STPTheme.default().primaryForegroundColor = .riderDarkBlueColor
        STPTheme.default().secondaryForegroundColor = .riderDarkGrayColor
        STPTheme.default().accentColor = .riderGreenColor
        
        // Main API client configuration
        PaymentAPIClient.shared.baseURLString = baseURLString
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        let UUID: UUID = iBeaconConfiguration.uuid!
        
        let beaconRegion: CLBeaconRegion = CLBeaconRegion(proximityUUID: UUID, identifier: "tw.darktt.beaconDemo")
        beaconRegion.notifyEntryStateOnDisplay = true
        
        self.locationManager.delegate = self
        self.locationManager.startMonitoring(for: beaconRegion)
        
        return true
    }
    
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            switch AppDelegate.checkerFG {
            case 1: return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, options: options)
            case 0: return GIDSignIn.sharedInstance().handle(url,
                                                             sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,annotation: [:])
            default: return true
            }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        // Loading UI..
        SwiftSpinner.show("Logging to Google")
        // ...
        if let error = error {
            // ...
            print("Failed to log into Google: ", error)
            return
        }
        // Perform any operations on signed in user here.
        print("Successfully logged into Google: ", user)
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        print(credential)
        // ...
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                // ...
                print("Failed to create a Firebase user with Google account: ", error)
                return
                // ...
            }
            // User is signed in
            // ...
            print("Successfully logged into Firebase with Google: \(user?.uid as Any)")
            SwiftSpinner.hide()
            // Access the storyboard and fetch an instance of the view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewer")
            
            // Then push that view controller onto the navigation stack
            let rootViewController = self.window!.rootViewController as! UINavigationController
            rootViewController.pushViewController(viewController, animated: true)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Sisma")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

