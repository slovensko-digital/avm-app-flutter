import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var appService: AppService?
    
    // https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622921-application
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        appService = AppService(binaryMessenger: controller.binaryMessenger);
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623112-application
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // https://www.kodeco.com/813044-uiactivityviewcontroller-tutorial-sharing-data
        
        return appService?.onNewUri(url: url) ?? false
    }
}
