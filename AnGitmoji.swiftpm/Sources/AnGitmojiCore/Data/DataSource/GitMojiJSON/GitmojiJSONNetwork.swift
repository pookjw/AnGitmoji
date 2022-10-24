import Foundation

final class GitmojiJSONNetwork: GitmojiJSONDataSource {
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
}
