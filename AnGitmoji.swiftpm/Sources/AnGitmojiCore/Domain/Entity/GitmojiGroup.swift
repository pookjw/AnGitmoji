import CoreData
import CoreTransferable
import UniformTypeIdentifiers

public final class GitmojiGroup: NSManagedObject, @unchecked Sendable {
    public static var fetchRequest: NSFetchRequest<GitmojiGroup> {
        return .init(entityName: "GitmojiGroup")
    }
    
    @NSManaged public internal(set) var index: Int
    @NSManaged public var name: String
    @NSManaged public internal(set) var gitmojis: NSOrderedSet
    
    @objc(insertObject:inGitmojisAtIndex:)
    @NSManaged func insertIntoGitmojis(_ value: Gitmoji, at idx: Int)
    
    @objc(removeObjectFromGitmojisAtIndex:)
    @NSManaged func removeFromGitmojis(at idx: Int)
    
    @objc(insertGitmojis:atIndexes:)
    @NSManaged func insertIntoGitmojis(_ values: [Gitmoji], at indexes: NSIndexSet)
    
    @objc(removeGitmojisAtIndexes:)
    @NSManaged func removeFromGitmojis(at indexes: NSIndexSet)
    
    @objc(replaceObjectInGitmojisAtIndex:withObject:)
    @NSManaged func replaceGitmojis(at idx: Int, with value: Gitmoji)
    
    @objc(replaceGitmojisAtIndexes:withGitmoji:)
    @NSManaged func replaceGitmojis(at indexes: NSIndexSet, with values: [Gitmoji])
    
    @objc(addGitmojisObject:)
    @NSManaged func addToGitmojis(_ value: Gitmoji)
    
    @objc(removeGitmojisObject:)
    @NSManaged func removeFromGitmojis(_ value: Gitmoji)
    
    @objc(addGitmojis:)
    @NSManaged func addToGitmojis(_ values: NSOrderedSet)
    
    @objc(removeGitmojis:)
    @NSManaged func removeFromGitmojis(_ values: NSOrderedSet)
}

extension GitmojiGroup: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .json) { gitmojiGroup in
            return try await gitmojiGroup.data
        } importing: { data in
            return try await create(from: data)
        }
        
        FileRepresentation(
            contentType: .json,
            shouldAttemptToOpenInPlace: false // url is temporary
        ) { gitmojiGroup in
            let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
            let name: String = await gitmojiUseCase.conditionSafe {
                return gitmojiGroup.name
            }
            let data: Data = try await gitmojiGroup.data
            let temporaryDirectory: URL = FileManager.default.temporaryDirectory
            let resultURL: URL = temporaryDirectory
                .appending(component: name, directoryHint: .notDirectory)
                .appendingPathExtension(UTType.json.preferredFilenameExtension ?? "json")
            
            if FileManager.default.fileExists(atPath: resultURL.path(percentEncoded: false)) {
                try FileManager.default.removeItem(at: resultURL)
            }
            
            try data.write(to: resultURL, options: [.atomic])
            
            let sentTransferredFile: SentTransferredFile = .init(resultURL, allowAccessingOriginalFile: true)
            return sentTransferredFile
        } importing: { receivedTransferredFile in
            let data: Data = try Data(
                contentsOf: receivedTransferredFile.file,
                options: [.uncached]
            )
            
            let gitmojiGroup: GitmojiGroup = try await create(from: data)
            
            return gitmojiGroup
        }
    }
}

extension GitmojiGroup {
    private var data: Data {
        get async throws {
            let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
            
            let gitmojiJSONObjects: [GitmojiJSON.Object] = try await gitmojiUseCase.conditionSafe {
                let results: [GitmojiJSON.Object] = try gitmojis
                    .compactMap { object throws -> GitmojiJSON.Object? in
                        guard let gitmoji: Gitmoji = object as? Gitmoji else {
                            return nil
                        }
                        
                        let emoji: String = gitmoji.emoji
                        let emojiNumericReferencesValue: [UInt32] = emoji
                            .unicodeScalars
                            .map { $0.value }
                        let entity: String = emojiNumericReferencesValue
                            .map { "&#\($0);" }
                            .joined()
                        
                        let result: GitmojiJSON.Object = .init(
                            emoji: emoji,
                            entity: entity,
                            code: gitmoji.code,
                            description: gitmoji.detail,
                            name: gitmoji.name,
                            semver: gitmoji.semver
                        )
                        
                        return result
                    }
                
                return results
            }
            
            let gitmojiJSON: GitmojiJSON = .init(gitmojis: gitmojiJSONObjects)
            let encoder: JSONEncoder = .init()
            encoder.outputFormatting = .prettyPrinted
            let data: Data = try encoder.encode(gitmojiJSON)
            
            return data
        }
    }
    
    private static func create(from data: Data) async throws -> GitmojiGroup {
        let decoder: JSONDecoder = .init()
        let gitmojiJSON: GitmojiJSON = try decoder.decode(GitmojiJSON.self, from: data)
        
        let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCase.newGitmojiGroup
        
        try await gitmojiUseCase.conditionSafe {
            for gitmojiObject in gitmojiJSON.gitmojis {
                let gitmoji: Gitmoji = try await gitmojiUseCase.newGitmoji(to: gitmojiGroup, index: nil)
                
                gitmoji.emoji = gitmojiObject.emoji
                gitmoji.code = gitmojiObject.code
                gitmoji.detail = gitmojiObject.description
                gitmoji.name = gitmojiObject.name
                gitmoji.semver = gitmojiObject.semver
            }
        }
        
        return gitmojiGroup
    }
}
