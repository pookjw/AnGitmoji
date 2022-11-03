import Foundation

final class GitmojiJSONNetwork: GitmojiJSONDataSource {
    private var defaultGitmojiURL: URL? {
        // https://raw.githubusercontent.com/carloscuesta/gitmoji/master/src/data/gitmojis.json
        var components: URLComponents = .init()
        components.scheme = "https"
        components.host = "raw.githubusercontent.com"
        components.path = "/carloscuesta/gitmoji/master/src/data/gitmojis.json"
        return components.url
    }
    
    func gitmojiJSON(from url: URL) async throws -> GitmojiJSON {
        var request: URLRequest = .init(url: url)
        request.httpMethod = "GET"
        let session: URLSession = .init(configuration: .ephemeral)
        let (data, response): (Data, URLResponse) = try await session.data(for: request)
        
        guard let statusCode: Int = (response as? HTTPURLResponse)?.statusCode else {
            throw AGMError.failedToCastType
        }
        
        guard statusCode == 200 else {
            throw AGMError.invalidStatusCode(statusCode)
        }
        
        let jsonDecoder: JSONDecoder = .init()
        let results: GitmojiJSON = try jsonDecoder.decode(GitmojiJSON.self, from: data)
        
        return results
    }
    
    var defaultGitmojiJSON: GitmojiJSON {
        get async throws {
            guard let defaultGitmojiURL: URL else {
                throw AGMError.unexpectedNilValue
            }
            
            return try await gitmojiJSON(from: defaultGitmojiURL)
        }
    }
}
