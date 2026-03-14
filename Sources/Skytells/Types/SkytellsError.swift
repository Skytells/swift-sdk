import Foundation

/// Structured error returned by the Skytells API.
public struct SkytellsError: Error, Sendable, CustomStringConvertible {
    /// A machine-readable error identifier.
    public let errorId: String
    /// Human-readable error message.
    public let message: String
    /// Additional error details.
    public let details: String
    /// The HTTP status code associated with the error, or `0` for network errors.
    public let httpStatus: Int

    public var description: String {
        "SkytellsError(\(errorId)): \(message) — \(details) [HTTP \(httpStatus)]"
    }

    public init(message: String, errorId: String, details: String, httpStatus: Int = 0) {
        self.message = message
        self.errorId = errorId
        self.details = details
        self.httpStatus = httpStatus
    }
}

/// Raw API error shape returned by the server.
struct APIErrorResponse: Decodable {
    let status: Bool?
    let response: String?
    let error: APIErrorDetail?

    struct APIErrorDetail: Decodable {
        let httpStatus: Int?
        let message: String?
        let details: String?
        let errorId: String?

        enum CodingKeys: String, CodingKey {
            case httpStatus = "http_status"
            case message
            case details
            case errorId = "error_id"
        }
    }
}
