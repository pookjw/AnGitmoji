import SwiftUI
import AnGitmojiCore

struct GitmojiGroupListView: View {
    @Binding private var selectedGitmojiGroup: GitmojiGroup?
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.index, order: .reverse)
        ],
        predicate: nil,
        animation: .easeInOut
    ) private var fetchedGitmojiGroups: FetchedResults<GitmojiGroup>
    @ObservedObject private var viewModel: GitmojiGroupListViewModel = .init()
    @State private var tasks: Set<Task<Void, Never>> = .init()
    
    init(selectedGitmojiGroup: Binding<GitmojiGroup?>) {
        self._selectedGitmojiGroup = selectedGitmojiGroup
    }
    
    var body: some View {
        List(selection: $selectedGitmojiGroup) {
            ForEach(fetchedGitmojiGroups, id: \.self) { gitmojiGroup in
                Text("\(gitmojiGroup.name)")
                    .font(.title)
                    .contextMenu {
                        Button("Delete") {
                            tasks.insert(.detached { [viewModel] in
                                do {
                                    try await viewModel.remove(gitmojiGroup: gitmojiGroup)
                                } catch {
                                    fatalError(error.localizedDescription)
                                }
                            })
                        }
                    }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    let gitmojiGroup: GitmojiGroup = fetchedGitmojiGroups[index]
                    tasks.insert(.detached { [viewModel] in
                        do {
                            try await viewModel.remove(gitmojiGroup: gitmojiGroup)
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    })
                }
            }
            .onMove { indexSet, index in
                
            }
//            .onDrop(of: <#T##[UTType]#>, isTargeted: <#T##Binding<Bool>?#>, perform: <#T##([NSItemProvider], CGPoint) -> Bool##([NSItemProvider], CGPoint) -> Bool##(_ providers: [NSItemProvider], _ location: CGPoint) -> Bool#>)
        }
        .onChange(of: viewModel.nsPredicate) { newValue in
            fetchedGitmojiGroups.nsPredicate = newValue
        }
        .listStyle(SidebarListStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    tasks.insert(.detached { [viewModel] in
                        try! await viewModel.test_removeAllGitmojiGroups()
                        exit(0)
                    })
                } label: {
                    Image(systemName: "ant")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    tasks.insert(.detached { [viewModel] in
                        try! await viewModel.test_create()
                    })
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .searchable(text: $viewModel.searchText)
        .navigationTitle(Text("Gitmojis"))
    }
}

struct GitmojiGroupListView_Previews: PreviewProvider {
    static var previews: some View {
        GitmojiGroupListView(selectedGitmojiGroup: .constant(nil))
    }
}
