import SwiftUI
import CoreData
import AnGitmojiCore

struct MainView: View {
    @ObservedObject private var viewModel: MainViewModel = .init()
    @State private var selectedGitmojiGroup: GitmojiGroup?
    
    var body: some View {
        if let context: NSManagedObjectContext = viewModel.context {
            NavigationSplitView {
                GitmojiGroupListView(selectedGitmojiGroup: $selectedGitmojiGroup)
                    .environment(\.managedObjectContext, context)
            } detail: {
                GitmojiGroupDetailView()
                    .environment(\.managedObjectContext, context)
                    .environment(\.selectedGitmojiGroup, selectedGitmojiGroup)
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
