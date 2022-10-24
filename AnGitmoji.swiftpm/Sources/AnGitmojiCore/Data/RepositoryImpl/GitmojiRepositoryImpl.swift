import Foundation

final class GitmojiRepositoryImpl: GitmojiRepository {
    func gitmojiData(from url: URL) async throws -> Data {
        var request: URLRequest = .init(url: url)
        request.httpMethod = "GET"
        let session: URLSession = .init(configuration: .ephemeral)
        let (data, response): (Data, URLResponse) = try await session.data(for: request)
        
        guard let statusCode: Int = (response as? HTTPURLResponse)?.statusCode else {
            throw AGMError.typeCastingError
        }
        
        guard statusCode == 200 else {
            throw AGMError.invalidStatusCode(statusCode)
        }
        
        return data
    }
}
