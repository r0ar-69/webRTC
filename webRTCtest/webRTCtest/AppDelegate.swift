//
//  AppDelegate.swift
//  webRTCtest
//
//  Created by 清浦駿 on 2020/04/11.
//  Copyright © 2020 com.example. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let userDefault = UserDefaults.standard
    
    override init() {
        FirebaseApp.configure()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        showLoginView()
        
        return true
    }
    
    func showLoginView() {
        if userDefault.object(forKey: "uid") == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
            let storyBoard = UIStoryboard(name: "Login", bundle: nil)
            let initialViewController = storyBoard.instantiateViewController(withIdentifier: "firstView")
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
        }
    }
    
    // MARK: UISceneSession Lifecycle
    /*
     
     @available(iOS 13.0, *)
     func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
     // Called when a new scene session is being created.
     // Use this method to select a configuration to create the new scene with.
     return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
     }
     
     @available(iOS 13.0, *)
     func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
     // Called when the user discards a scene session.
     // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
     // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
     }
     
     */
    
}

