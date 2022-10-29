import SwiftUI

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .commands {
            CommandMenu("Test") {
                Text("Test")
            }
        }
    }
}
