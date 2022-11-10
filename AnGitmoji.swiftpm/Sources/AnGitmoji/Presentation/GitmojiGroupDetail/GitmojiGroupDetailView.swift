import SwiftUI
import AnGitmojiCore

struct GitmojiGroupDetailView: View {
    @FetchRequest(
        sortDescriptors: [.init(\.name, order: .forward)],
        // When change of selectedGitmojiGroup is detected, there's no predicate in short time.
        // During that time, this view will show all Gitmoji objects without filtering. Below code will prevent it.
        predicate: NSPredicate(value: false),
        animation: .easeInOut
    ) private var fetchedGitmojis: FetchedResults<Gitmoji>
    @ObservedObject private var viewModel: GitmojiGroupDetailViewModel
    @State private var tasks: Set<Task<Void, Never>> = .init()
    
    init(selectedGitmojiGroup: GitmojiGroup) {
        viewModel = .init(selectedGitmojiGroup: selectedGitmojiGroup)
    }
    
    var body: some View {
        Table(selection: $viewModel.selectedGitmojis, sortOrder: $viewModel.sortDescriptors) {
            TableColumn("Name", value: \Gitmoji.name)
            TableColumn("Emoji", value: \Gitmoji.emoji)
            TableColumn("Code", value: \Gitmoji.code)
            TableColumn("Description", value: \Gitmoji.detail) { gitmoji in
                Text(gitmoji.detail)
                    .lineLimit(nil)
            }
            TableColumn("Count", value: \Gitmoji.count) { gitmoji in
                Text("\(gitmoji.count)")
            }
        } rows: {
            ForEach(fetchedGitmojis) { gitmoji in
                TableRow(gitmoji)
                    .contextMenu {
                        Button {
                            tasks.insert(.detached { [viewModel] in
                                await viewModel.prepareEditAlert(gitmoji: gitmoji)
                            })
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button {
                            tasks.insert(.detached { [viewModel] in
                                do {
                                    try await viewModel.copy(gitmoji: gitmoji)
                                } catch {
                                    fatalError("\(error)")
                                }
                            })
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        
                        Button {
                            tasks.insert(.detached { [viewModel] in
                                do {
                                    try await viewModel.remove(gitmoji: gitmoji)
                                } catch {
                                    fatalError("\(error)")
                                }
                            })
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Divider()
                        
                        Button {
                            tasks.insert(.detached { [viewModel] in
                                do {
                                    try await viewModel.resetCount(gitmoji: gitmoji)
                                } catch {
                                    fatalError("\(error)")
                                }
                                
                            })
                        } label: {
                            Label("Reset Count", systemImage: "arrow.triangle.2.circlepath")
                        }
                    }
            }
        }
        .onChange(of: viewModel.sortDescriptors) { newValue in
            fetchedGitmojis.sortDescriptors = newValue
        }
        .onChange(of: viewModel.nsPredicate) { newValue in
            fetchedGitmojis.nsPredicate = newValue
        }
        .navigationTitle(viewModel.selectedGitmojiGroupName)
        .searchable(text: $viewModel.searchText)
        .alert("Edit Gitmoji", isPresented: $viewModel.isPresentedEditAlert) {
            TextField("Enter emoji here...", text: $viewModel.editingGitmojiEmoji)
            TextField("Enter code here...", text: $viewModel.editingGitmojiCode)
            TextField("Enter name here...", text: $viewModel.editingGitmojiName)
            TextField("Enter detail here...", text: $viewModel.editingGitmojiDetail)
            
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
    }
}

struct GitmojiGroupDetailViewl_Previews: PreviewProvider {
    static var previews: some View {
        GitmojiGroupDetailView(selectedGitmojiGroup: .init())
    }
}
