import UIKit
import AnGitmojiObjC

final class AppDelegate: NSObject, UIApplicationDelegate {
#if os(macOS) || targetEnvironment(macCatalyst)
//    private let s: GitmojiGroupsStatusMenuItem = .init()
#endif
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}
