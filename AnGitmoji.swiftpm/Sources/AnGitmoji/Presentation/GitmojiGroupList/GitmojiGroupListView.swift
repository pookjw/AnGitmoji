import SwiftUI
import UniformTypeIdentifiers
import AnGitmojiCore

struct GitmojiGroupListView: View {
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\GitmojiGroup.index, order: .reverse)
        ],
        predicate: nil,
        animation: .easeInOut
    ) private var fetchedGitmojiGroups: FetchedResults<GitmojiGroup>
    @State private var isEditing: Bool = false
    @State private var isDropping: Bool = false
    @ObservedObject private var viewModel: GitmojiGroupListViewModel
    @State private var tasks: Set<Task<Void, Never>> = .init()
    
    init(selectedGitmojiGroups: Binding<Set<GitmojiGroup>>) {
        self.viewModel = .init(selectedGitmojiGroups: selectedGitmojiGroups)
    }
    
    var body: some View {
        Group {
            List(selection: viewModel.$selectedGitmojiGroups) {
                ForEach(fetchedGitmojiGroups, id: \.self) { gitmojiGroup in
                    Text("\(gitmojiGroup.name)")
                        .font(.title)
                        .contextMenu {
                            Button {
                                tasks.insert(.detached { [viewModel] in
                                    await viewModel.prepareEditAlert(gitmojiGroup: gitmojiGroup)
                                })
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button {
                                tasks.insert(.detached { [viewModel] in
                                    do {
                                        try await viewModel.remove(gitmojiGroup: gitmojiGroup)
                                    } catch {
                                        fatalError(error.localizedDescription)
                                    }
                                })
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Divider()
                            
                            ShareLink(
                                item: gitmojiGroup,
                                preview: SharePreview("Share", image: Image(systemName: "xmark"))
                            )
                        }
                        .onDrag {
                            let itemProvider: NSItemProvider = .init()
                            itemProvider.register(gitmojiGroup)
                            return itemProvider
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
                    tasks.insert(.detached { [viewModel] in
                        do {
                            try await viewModel.move(of: indexSet, to: index)
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    })
                }
                .onDrop(of: [.json], isTargeted: $isDropping) { itemProviders in
                    tasks.insert(.detached { [viewModel] in
                        do {
                            try await viewModel.load(itemProviders: itemProviders)
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    })
                    return true
                }
            }
            
            EditableView(isEditing: $isEditing)
        }
        .onChange(of: viewModel.nsPredicate) { newValue in
            fetchedGitmojiGroups.nsPredicate = newValue
        }
        .listStyle(SidebarListStyle())
        .contextMenu {
            if !viewModel.selectedGitmojiGroups.isEmpty {
                Button {
                    tasks.insert(.detached { [viewModel] in
                        do {
                            try await viewModel.removeSelectedGitmojiGroups()
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    })
                } label: {
                    Label("Delete Selected Groups", systemImage: "trash")
                }
            }
            
            Button {
                tasks.insert(.detached { [viewModel] in
                    do {
                        try await viewModel.test_create()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                })
            } label: {
                Label("Create a new Group", systemImage: "plus")
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            
#if DEBUG
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
#endif
            
            if isEditing {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(viewModel.selectedGitmojiGroups.isEmpty)
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
        .alert("Edit Group name", isPresented: $viewModel.isPresentedEditAlert) {
            TextField("Enter name here...", text: $viewModel.editingGitmojiGroupName)
            
            Button("OK", role: .cancel) {
                tasks.insert(.detached { [viewModel] in
                    do {
                        try await viewModel.endEditAlert(finished: true)
                    } catch {
                        fatalError("\(error)")
                    }
                })
            }
            
            Button("Cancel", role: .destructive) {
                tasks.insert(.detached { [viewModel] in
                    do {
                        try await viewModel.endEditAlert(finished: false)
                    } catch {
                        fatalError("\(error)")
                    }
                })
            }
        }
        .navigationTitle(Text("Gitmojis"))
    }
}

struct GitmojiGroupListView_Previews: PreviewProvider {
    static var previews: some View {
        GitmojiGroupListView(selectedGitmojiGroups: .constant(.init()))
    }
}
