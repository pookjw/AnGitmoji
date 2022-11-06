import SwiftUI
import CoreData
import AnGitmojiCore

struct MainView: View {
    @StateObject private var viewModel: MainViewModel = .init()
    @State private var selectedGitmojiGroups: Set<GitmojiGroup> = .init()
    @State private var presentedGitmojiGroup: GitmojiGroup?
    
    var body: some View {
        Group {
            if let context: NSManagedObjectContext = viewModel.context {
                NavigationSplitView {
                    GitmojiGroupListView(selectedGitmojiGroups: $selectedGitmojiGroups)
                        .environment(\.managedObjectContext, context)
                } detail: {
                    if let presentedGitmojiGroup: GitmojiGroup {
                        GitmojiGroupDetailView(selectedGitmojiGroup: presentedGitmojiGroup)
                            .environment(\.managedObjectContext, context)
                    } else {
                        Text("No Selection")
                    }
                }
            } else {
                EmptyView()
            }
        }
        .onChange(of: selectedGitmojiGroups) { newValue in
            guard newValue.count == 1,
                  let selectedGitmojiGroup: GitmojiGroup = newValue.first else {
                presentedGitmojiGroup = nil
                return
            }
            
            presentedGitmojiGroup = selectedGitmojiGroup
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
