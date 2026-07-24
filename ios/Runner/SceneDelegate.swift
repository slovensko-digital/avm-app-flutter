import Flutter
import UIKit

@objc(SceneDelegate)
class SceneDelegate: FlutterSceneDelegate {
    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)

        handle(connectionOptions: connectionOptions)
    }

    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        super.scene(scene, openURLContexts: URLContexts)

        for context in URLContexts {
            _ = appDelegate?.handleIncoming(url: context.url)
        }
    }

    override func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        super.scene(scene, continue: userActivity)

        _ = appDelegate?.handleIncoming(userActivity: userActivity)
    }

    private var appDelegate: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }

    private func handle(connectionOptions: UIScene.ConnectionOptions) {
        for context in connectionOptions.urlContexts {
            _ = appDelegate?.handleIncoming(url: context.url)
        }

        for userActivity in connectionOptions.userActivities {
            _ = appDelegate?.handleIncoming(userActivity: userActivity)
        }
    }
}