import SwiftUI
import AnGitmojiCore

struct GitmojiGroupListView: View {
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.index, order: .reverse)
        ],
        predicate: nil,
        animation: .default
    ) private var fetchedGitmojiGroups: FetchedResults<GitmojiGroup>
    @ObservedObject private var viewModel: GitmojiGroupListViewModel = .init()
    
    var body: some View {
        List(fetchedGitmojiGroups, id: \.objectID, rowContent: { gitmoji in
            Text("\(gitmoji.name)")
                .font(.title)
        })
        .listStyle(SidebarListStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.test()
                } label: {
                    Image(systemName: "ant")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.test()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle(Text("Gitmojis"))
    }
}

struct GitmojiGroupListView_Previews: PreviewProvider {
    static var previews: some View {
        GitmojiGroupListView()
    }
}
