import Foundation

public enum AGMError: Error {
    case failedToFoundMomdURL(modelName: String)
    case failedToInitManagedObjectModel(modelName: String)
    case failedToGetEntityNameFromFetchRequest
    case invalidStatusCode(Int)
    case failedToCastType
    case unexpectedNilValue
    case outOfIndex
    case noGitmojiGroup
    case gotNSNotFound
    case gitmojiWasDeleted
}
