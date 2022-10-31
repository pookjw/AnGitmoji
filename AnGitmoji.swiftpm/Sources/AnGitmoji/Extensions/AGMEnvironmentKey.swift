import SwiftUI
import AnGitmojiCore

struct AGMEnvironmentKey {
    struct SelectedGitmojiGroup: EnvironmentKey {
        static let defaultValue: GitmojiGroup? = nil
    }
}

extension EnvironmentValues {
    var selectedGitmojiGroup: GitmojiGroup? {
        get {
            self[AGMEnvironmentKey.SelectedGitmojiGroup.self]
        }
        set {
            self[AGMEnvironmentKey.SelectedGitmojiGroup.self] = newValue
        }
    }
}
