import Foundation

// MARK: - Enums

/// The privacy level of a model.
public enum ModelPrivacy: String, Codable, Sendable {
    case `public` = "public"
    case `private` = "private"
}

/// The media type a model operates on.
public enum ModelType: String, Codable, Sendable {
    case image = "image"
    case video = "video"
    case audio = "audio"
    case music = "music"
    case text = "text"
}

/// The unit used for pricing.
public enum PricingUnit: String, Codable, Sendable {
    case image = "image"
    case video = "video"
    case audio = "audio"
    case second = "second"
    case prediction = "prediction"
    case gpu = "gpu"
    case megapixel = "megapixel"
    case token = "token"
    case tokens = "tokens"
    case imageMegapixel = "image_megapixel"
}

/// Operator used in pricing criteria.
public enum PricingOperator: String, Codable, Sendable {
    case equals = "equals"
}

// MARK: - Models

/// A condition that affects billing.
public struct PricingCriteria: Codable, Sendable {
    public let field: String
    public let description: String
    public let `operator`: PricingOperator
    public let value: AnyCodableValue
    public let billablePrice: Double
    public let unit: String

    enum CodingKeys: String, CodingKey {
        case field, description
        case `operator`
        case value
        case billablePrice = "billable_price"
        case unit
    }
}

/// Pricing information for a model.
public struct Pricing: Codable, Sendable {
    public let amount: Double
    public let currency: String
    public let unit: String
    public let criterias: [PricingCriteria]?
}

/// The vendor that provides a model.
public struct Vendor: Codable, Sendable {
    public let name: String
    public let description: String
    public let imageURL: String
    public let verified: Bool
    public let slug: String
    public let metadata: AnyCodableValue?

    enum CodingKeys: String, CodingKey {
        case name, description
        case imageURL = "image_url"
        case verified, slug, metadata
    }
}

/// Service information for a model.
public struct Service: Codable, Sendable {
    public let type: String
    public let inferenceParty: String

    enum CodingKeys: String, CodingKey {
        case type
        case inferenceParty = "inference_party"
    }
}

/// A model available on the Skytells platform.
public struct Model: Codable, Sendable {
    public let name: String
    public let description: String?
    public let namespace: String
    public let type: ModelType
    public let privacy: ModelPrivacy
    public let imgURL: String?
    public let vendor: Vendor
    public let billable: Bool?
    public let pricing: Pricing?
    public let capabilities: [String]
    public let status: String
    public let service: Service?

    enum CodingKeys: String, CodingKey {
        case name, description, namespace, type, privacy
        case imgURL = "img_url"
        case vendor, billable, pricing, capabilities, status, service
    }
}
