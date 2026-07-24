import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    var appService: AppService?
    private var pendingIncomingUrl: URL?

    private func isSupportedIncoming(url: URL) -> Bool {
        url.isFileURL || ["https", "avm"].contains(url.scheme)
    }

    func handleIncoming(url: URL) -> Bool {
        guard isSupportedIncoming(url: url) else {
            return false
        }

        guard let appService else {
            pendingIncomingUrl = url
            return true
        }

        pendingIncomingUrl = nil
        return appService.onNewUri(url: url)
    }

    func handleIncoming(userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }

        return handleIncoming(url: url)
    }

    /// Handles app startup.
    /// https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622921-application
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    /// Handles Open with / Share actions and also custom URI scheme.
    /// https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623112-application
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {

        // let sourceApplication = options[.sourceApplication]
        // let openInPlace = options[.openInPlace]
        // TODO Check source and fix URL encoding "%3D"

        return handleIncoming(url: url)
    }

    /// iOS "Universal link" handler.
    /// https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623072-application
    override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        return handleIncoming(userActivity: userActivity)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

        let appService = AppService(binaryMessenger: engineBridge.applicationRegistrar.messenger())
        self.appService = appService

        if let pendingIncomingUrl {
            _ = appService.onNewUri(url: pendingIncomingUrl)
            self.pendingIncomingUrl = nil
        }
    }
}
