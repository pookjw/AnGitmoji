import SwiftUI
import CoreData
import AnGitmojiCore

struct MainView: View {
    @ObservedObject private var viewModel: MainViewModel = .init()
    @State private var selectedGitmojiGroup: GitmojiGroup?
    
    var body: some View {
        if let context: NSManagedObjectContext = viewModel.context {
            NavigationSplitView {
                GitmojiGroupListView()
                    .environment(\.managedObjectContext, context)
            } detail: {
                GitmojiGroupDetailView()
                    .environment(\.managedObjectContext, context)
            }
        } else {
            EmptyView()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
