import Foundation
import CoreTransferable

struct GitmojiJSON: Codable {
    struct Object: Codable {
        let emoji: String
        let entity: String
        let code: String
        let description: String
        let name: String
        let semver: String?
    }
    
    let gitmojis: [Object]
}

extension GitmojiJSON: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}
