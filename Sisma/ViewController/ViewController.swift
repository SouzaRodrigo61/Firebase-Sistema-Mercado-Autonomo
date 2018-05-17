//
//  ViewController.swift
//  Sisma
//
//  Created by Rodrigo Santos on 05/05/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    

    private func setupGoogleButtons(){
        let signInButton = GIDSignInButton(frame: CGRect(x: 87, y: 510, width: 200, height: 50))
        view.addSubview(signInButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }
    
    private func setupFacebookButtons(){

        let loginButton = FBSDKLoginButton(frame: CGRect(x: 87, y: 540, width: 200, height: 50))
        loginButton.delegate = self
        view.addSubview(loginButton)
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (facebookResult, facebookError) in
            if facebookError != nil {
                //                displayAlertMessage(messageToDisplay: "There was an error logging in to Facebook. Error: \(facebookError)", viewController: self)
            } else{
                if (facebookResult?.isCancelled)!{
                    print("Facebook login was cancelled!")
                }
                else {
                    // self.startActivityIndicator()
                    let credential = (FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString))
                    //signin in Firebase
                    Auth.auth().signIn(with: credential, completion: { (user, error) in
                        print("Successfully logged into Firebase with Facebook: \(user?.uid as Any)")
                        if user != nil{
                            if user?.email != nil && user?.uid != nil {
                            }
//                            self.performSegue(withIdentifier: "buttonView", sender: self)
                        }else{
                            //error: check error and show message
                            //displayAlertMessage(messageToDisplay: "Проверьте подключение к интернету ", viewController: self )
                        }
                    })
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupGoogleButtons()
//        setupFacebookButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Implement these methods only if the GIDSignInUIDelegate is not a subclass of
    // UIViewController.
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
//    private func signInWillDispatch(signIn: GIDSignIn!, error: Error!) {
//        myActivityIndicator.stopAnimating()
//    }
    
    // Present a view that prompts the user to sign in with Google
    private func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    private func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }

}

