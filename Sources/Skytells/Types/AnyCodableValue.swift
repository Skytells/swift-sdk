import Foundation

/// A type-erased `Codable` value used for dynamic JSON fields.
///
/// Supports strings, booleans, integers, doubles, arrays, dictionaries, and null.
public enum AnyCodableValue: Sendable, Hashable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case array([AnyCodableValue])
    case dictionary([String: AnyCodableValue])
    case null
}

// MARK: - Codable

extension AnyCodableValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([AnyCodableValue].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: AnyCodableValue].self) {
            self = .dictionary(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .bool(let value):   try container.encode(value)
        case .int(let value):    try container.encode(value)
        case .double(let value): try container.encode(value)
        case .array(let value):  try container.encode(value)
        case .dictionary(let value): try container.encode(value)
        case .null:              try container.encodeNil()
        }
    }
}

// MARK: - ExpressibleBy literals

extension AnyCodableValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) { self = .string(value) }
}

extension AnyCodableValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) { self = .bool(value) }
}

extension AnyCodableValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) { self = .int(value) }
}

extension AnyCodableValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) { self = .double(value) }
}

extension AnyCodableValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: AnyCodableValue...) { self = .array(elements) }
}

extension AnyCodableValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, AnyCodableValue)...) {
        self = .dictionary(Dictionary(uniqueKeysWithValues: elements))
    }
}

extension AnyCodableValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) { self = .null }
}
