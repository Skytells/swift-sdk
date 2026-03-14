import Foundation

/// API base URL and endpoint paths for the Skytells API.
enum Endpoints {
    static let baseURL = "https://api.skytells.ai/v1"

    static let predict = "/predict"
    static let models  = "/models"

    static func prediction(id: String) -> String { "/predictions/\(id)" }
    static func streamPrediction(id: String) -> String { "/predictions/\(id)/stream" }
    static func cancelPrediction(id: String) -> String { "/predictions/\(id)/cancel" }
    static func deletePrediction(id: String) -> String { "/predictions/\(id)/delete" }
}
