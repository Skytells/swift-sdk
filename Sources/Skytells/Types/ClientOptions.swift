import Foundation

/// Configuration options for the Skytells client.
public struct ClientOptions: Sendable {
    /// Override the API base URL. Defaults to `https://api.skytells.ai/v1`.
    public var baseURL: String?
    /// Request timeout interval in seconds. Defaults to 60.
    public var timeout: TimeInterval?

    public init(baseURL: String? = nil, timeout: TimeInterval? = nil) {
        self.baseURL = baseURL
        self.timeout = timeout
    }
}
