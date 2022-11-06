import SwiftUI

// https://developer.apple.com/forums/thread/125823?answerId=394424022#394424022

struct EditableView: View {
    @Binding var isEditing: Bool
    @Environment(\.editMode) private var editMode: Binding<EditMode>?
    
    var body: some View {
        EmptyView()
            .onReceive(editMode.publisher) { newValue in
                isEditing = newValue.wrappedValue.isEditing
            }
    }
}
