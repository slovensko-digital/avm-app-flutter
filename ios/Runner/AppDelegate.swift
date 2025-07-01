import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    var appService: AppService?
    
    /// Handles app startup.
    /// https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622921-application
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        appService = AppService(binaryMessenger: controller.binaryMessenger);
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /// Handles Open with / Share actions and also custom URI scheme.
    /// https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623112-application
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        // let sourceApplication = options[.sourceApplication]
        // let openInPlace = options[.openInPlace]
        // TODO Check source and fix URL encoding "%3D"
        
        return appService?.onNewUri(url: url) ?? false
    }
    
    /// iOS "Universal link" handler.
    /// https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623072-application
    override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
            // Handle the incoming universal link URL
            return appService?.onNewUri(url: url) ?? false
        }

        return false
    }
}
