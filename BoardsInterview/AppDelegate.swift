//
//  AppDelegate.swift
//  BoardsInterview
//
//  Created by Maulik Vekariya on 12/8/17.
//  Copyright © 2017 Maulik Vekariya. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import Reachability

let googleApiKey = "AIzaSyBzKn292ZrqyZ_Rfqp7bHLmy3b8dWwayAM"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var internetConnection : Bool = false
    var baseURL = ""
    var dictSetting:NSDictionary!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        GMSServices.provideAPIKey(googleApiKey)
        GMSPlacesClient.provideAPIKey(googleApiKey)
        
        IQKeyboardManager.sharedManager().enable = true
        
        let pathSetting = Bundle.main.path(forResource: "Settings", ofType: "plist")
        dictSetting = NSDictionary(contentsOfFile: pathSetting!)
        
        baseURL = dictSetting?.object(forKey: "baseURL") as! String;
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.black
        self.checkConnection()
        self.setViews()
        
        // Override point for customization after application launch.
        return true
    }

    func setViews()
    {
        let rtView1 = ViewController(nibName: "ViewController", bundle: nil)
        let nav1 = UINavigationController(rootViewController: rtView1)
        
        self.window?.rootViewController = nav1;
        self.window!.makeKeyAndVisible()
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
    }

    // MARK: - InterntConnection
    
    func checkConnection()
    {
        let reachability = Reachability()!
        
        //declare this inside of viewWillAppear
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: Notification.Name.reachabilityChanged,object: reachability)
        do
        {
            try reachability.startNotifier()
        }
        catch
        {
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: NSNotification)
    {
        
        let reachability = Reachability()!
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
                self.internetConnection = true
            } else {
                print("Reachable via Cellular")
                self.internetConnection = true
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            self.internetConnection = false
            self.displayAlert(strMessage: "You've disconnected. Please check your internet connection.");

        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func displayAlert(strMessage: String)
    {
        let alertController = UIAlertController(title: Appname, message: strMessage, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}

