import Foundation

// MARK: - Request

/// A webhook configuration for receiving prediction events.
public struct PredictionWebhook: Codable, Sendable {
    /// The URL to receive webhook events.
    public let url: String?
    /// The events to subscribe to.
    public let events: [String]

    public init(url: String? = nil, events: [String] = []) {
        self.url = url
        self.events = events
    }
}

/// The payload for creating a prediction.
public struct PredictionRequest: Encodable, Sendable {
    /// The model identifier (e.g. `"vendor/model-name"`).
    public let model: String
    /// Input parameters for the prediction.
    public let input: [String: AnyCodableValue]
    /// Optional webhook to receive prediction lifecycle events.
    public let webhook: PredictionWebhook?
    /// When `true`, the request blocks until the prediction completes.
    public let `await`: Bool?
    /// When `true`, enables streaming of prediction events.
    public let stream: Bool?

    public init(
        model: String,
        input: [String: AnyCodableValue],
        webhook: PredictionWebhook? = nil,
        await: Bool? = nil,
        stream: Bool? = nil
    ) {
        self.model = model
        self.input = input
        self.webhook = webhook
        self.await = `await`
        self.stream = stream
    }
}

// MARK: - Response enums

/// The status of a prediction.
public enum PredictionStatus: String, Codable, Sendable {
    case pending = "pending"
    case processing = "processing"
    case succeeded = "succeeded"
    case failed = "failed"
    case cancelled = "cancelled"
    case starting = "starting"
    case started = "started"
}

/// The type of prediction.
public enum PredictionType: String, Codable, Sendable {
    case inference = "inference"
    case training = "training"
}

/// The source that initiated the prediction.
public enum PredictionSource: String, Codable, Sendable {
    case api = "api"
    case cli = "cli"
    case web = "web"
}

// MARK: - Response

/// Metrics about a completed prediction.
public struct PredictionMetrics: Codable, Sendable {
    public let imageCount: Int?
    public let predictTime: Double?
    public let totalTime: Double?
    public let assetCount: Int?

    enum CodingKeys: String, CodingKey {
        case imageCount = "image_count"
        case predictTime = "predict_time"
        case totalTime = "total_time"
        case assetCount = "asset_count"
    }
}

/// A file stored as part of prediction output.
public struct PredictionStorageFile: Codable, Sendable {
    public let name: String
    public let type: String
    public let size: Int
    public let url: String
}

/// Storage metadata for a prediction.
public struct PredictionStorage: Codable, Sendable {
    public let files: [PredictionStorageFile]?
}

/// Billing metadata for a prediction.
public struct PredictionBilling: Codable, Sendable {
    public let creditsUsed: Double?

    enum CodingKeys: String, CodingKey {
        case creditsUsed = "credits_used"
    }
}

/// Metadata attached to a prediction.
public struct PredictionMetadata: Codable, Sendable {
    public let billing: PredictionBilling?
    public let storage: PredictionStorage?
    public let dataAvailable: Bool?

    enum CodingKeys: String, CodingKey {
        case billing, storage
        case dataAvailable = "data_available"
    }
}

/// URL actions available for a prediction.
public struct PredictionURLs: Codable, Sendable {
    public let get: String?
    public let cancel: String?
    public let stream: String?
    public let delete: String?
}

/// Model summary included in a prediction response.
public struct PredictionModel: Codable, Sendable {
    public let name: String
    public let type: String
}

/// The response returned by the Skytells API for predictions.
public struct PredictionResponse: Codable, Sendable {
    public let status: PredictionStatus
    public let id: String
    public let type: PredictionType
    public let response: String?
    public let stream: Bool
    public let input: [String: AnyCodableValue]?
    public let output: AnyCodableValue?
    public let createdAt: String
    public let startedAt: String?
    public let completedAt: String?
    public let updatedAt: String
    public let privacy: String
    public let source: PredictionSource?
    public let model: PredictionModel?
    public let webhook: PredictionWebhook?
    public let metrics: PredictionMetrics?
    public let metadata: PredictionMetadata?
    public let urls: PredictionURLs?

    enum CodingKeys: String, CodingKey {
        case status, id, type, response, stream, input, output
        case createdAt = "created_at"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case updatedAt = "updated_at"
        case privacy, source, model, webhook, metrics, metadata, urls
    }
}

// MARK: - Output convenience accessors

extension PredictionResponse {
    /// The output interpreted as an array of URL strings, or `nil` if the output is not an array of strings.
    public var outputURLs: [String]? {
        guard case .array(let items) = output else { return nil }
        return items.compactMap { item -> String? in
            guard case .string(let value) = item else { return nil }
            return value
        }
    }

    /// The first output URL string, or `nil` if unavailable.
    public var firstOutputURL: String? {
        outputURLs?.first
    }

    /// The output interpreted as a single string, or `nil` if the output is not a string.
    public var outputString: String? {
        if case .string(let value) = output { return value }
        return nil
    }

    /// The output interpreted as an array of dictionaries, or `nil` if the output is not in that shape.
    public var outputObjects: [[String: AnyCodableValue]]? {
        guard case .array(let items) = output else { return nil }
        return items.compactMap { item -> [String: AnyCodableValue]? in
            guard case .dictionary(let dict) = item else { return nil }
            return dict
        }
    }
}
