import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationSplitView {
            GitmojiGroupListView()
        } detail: {
            GitmojiGroupDetailView()
        }

    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
