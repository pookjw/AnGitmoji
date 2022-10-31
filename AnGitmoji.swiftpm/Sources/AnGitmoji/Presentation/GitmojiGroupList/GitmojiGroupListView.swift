import SwiftUI
import AnGitmojiCore

struct GitmojiGroupListView: View {
    @Binding private var selectedGitmojiGroup: GitmojiGroup?
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.index, order: .reverse)
        ],
        animation: .default
    ) private var fetchedGitmojiGroups: FetchedResults<GitmojiGroup>
    @ObservedObject private var viewModel: GitmojiGroupListViewModel = .init()
    
    init(selectedGitmojiGroup: Binding<GitmojiGroup?>) {
        self._selectedGitmojiGroup = selectedGitmojiGroup
    }
    
    var body: some View {
        List(selection: $selectedGitmojiGroup) {
            ForEach(fetchedGitmojiGroups, id: \.self) { gitmojiGroup in
                Text("\(gitmojiGroup.name)")
                    .font(.title)
            }
            .onDelete { indexSet in
                
            }
            .onMove { indexSet, index in
                
            }
//            .onDrop(of: <#T##[UTType]#>, isTargeted: <#T##Binding<Bool>?#>, perform: <#T##([NSItemProvider], CGPoint) -> Bool##([NSItemProvider], CGPoint) -> Bool##(_ providers: [NSItemProvider], _ location: CGPoint) -> Bool#>)
        }
        .listStyle(SidebarListStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.test_removeAll()
                } label: {
                    Image(systemName: "ant")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.test_create()
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
        GitmojiGroupListView(selectedGitmojiGroup: .constant(nil))
    }
}
