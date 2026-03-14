import Foundation

/// The Skytells API client.
///
/// Create an instance using ``SkytellsClient/init(apiKey:options:)`` or the
/// convenience factory ``Skytells/createClient(apiKey:options:)``.
///
/// ```swift
/// let client = SkytellsClient(apiKey: "sk-...")
///
/// let prediction = try await client.predict(.init(
///     model: "vendor/model",
///     input: ["prompt": "A sunset over the ocean"]
/// ))
/// ```
public final class SkytellsClient: Sendable {
    private let http: HTTPClient

    /// Creates a new Skytells client.
    /// - Parameters:
    ///   - apiKey: Your Skytells API key.
    ///   - options: Optional configuration overrides.
    public init(apiKey: String? = nil, options: ClientOptions = .init()) {
        self.http = HTTPClient(
            apiKey: apiKey,
            baseURL: options.baseURL ?? Endpoints.baseURL,
            timeout: options.timeout ?? 60
        )
    }

    // MARK: - Predictions

    /// Send a prediction request.
    /// - Parameter payload: The prediction request parameters.
    /// - Returns: The prediction response.
    public func predict(_ payload: PredictionRequest) async throws -> PredictionResponse {
        try await http.request(method: "POST", path: Endpoints.predict, body: payload)
    }

    /// Retrieve a prediction by its ID.
    /// - Parameter id: The prediction identifier.
    /// - Returns: The prediction response.
    public func getPrediction(id: String) async throws -> PredictionResponse {
        try await http.request(method: "GET", path: Endpoints.prediction(id: id))
    }

    /// Stream a prediction by its ID.
    /// - Parameter id: The prediction identifier.
    /// - Returns: The prediction response.
    public func streamPrediction(id: String) async throws -> PredictionResponse {
        try await http.request(method: "GET", path: Endpoints.streamPrediction(id: id))
    }

    /// Cancel a running prediction.
    /// - Parameter id: The prediction identifier.
    /// - Returns: The updated prediction response.
    public func cancelPrediction(id: String) async throws -> PredictionResponse {
        try await http.request(method: "POST", path: Endpoints.cancelPrediction(id: id))
    }

    /// Delete a prediction.
    /// - Parameter id: The prediction identifier.
    /// - Returns: The prediction response.
    public func deletePrediction(id: String) async throws -> PredictionResponse {
        try await http.request(method: "DELETE", path: Endpoints.deletePrediction(id: id))
    }

    // MARK: - Models

    /// List all available models.
    /// - Returns: An array of models.
    public func listModels() async throws -> [Model] {
        try await http.request(method: "GET", path: Endpoints.models)
    }
}
