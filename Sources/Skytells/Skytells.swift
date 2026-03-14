import Foundation

/// The Skytells Swift SDK namespace.
public enum Skytells {
    /// The current version of the SDK.
    public static let version = "1.0.0"

    /// The default API base URL.
    public static let apiBaseURL = Endpoints.baseURL

    /// Create a new Skytells API client.
    /// - Parameters:
    ///   - apiKey: Optional API key for authenticated requests.
    ///   - options: Optional client configuration.
    /// - Returns: A configured ``SkytellsClient`` instance.
    public static func createClient(apiKey: String? = nil, options: ClientOptions = .init()) -> SkytellsClient {
        SkytellsClient(apiKey: apiKey, options: options)
    }
}
