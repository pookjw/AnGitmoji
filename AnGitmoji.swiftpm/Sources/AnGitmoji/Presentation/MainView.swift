import SwiftUI
import AnGitmojiObjC
import AnGitmojiCore

struct MainView: View {
    var body: some View {
        NavigationSplitView {
            Text("Test 1")
        } content: {
            Text("Test 1")
        } detail: {
            Text("Test 1")
        }
        .onAppear {
            
        }

    }
}
