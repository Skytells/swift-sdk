import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Low-level HTTP transport for the Skytells API.
final class HTTPClient: @unchecked Sendable {
    private let session: URLSession
    private let baseURL: String
    private let apiKey: String?
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(apiKey: String?, baseURL: String = Endpoints.baseURL, timeout: TimeInterval = 60) {
        self.apiKey = apiKey
        self.baseURL = baseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    // MARK: - Public

    func request<T: Decodable>(method: String, path: String) async throws -> T {
        let request = try buildRequest(method: method, path: path)
        return try await execute(request)
    }

    func request<T: Decodable, Body: Encodable>(method: String, path: String, body: Body) async throws -> T {
        var request = try buildRequest(method: method, path: path)
        request.httpBody = try encoder.encode(body)
        return try await execute(request)
    }

    // MARK: - Private

    private func buildRequest(method: String, path: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw SkytellsError(
                message: "Invalid URL: \(baseURL)\(path)",
                errorId: "INVALID_URL",
                details: "Could not construct a valid URL from the base URL and path"
            )
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        }

        return request
    }

    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError where urlError.code == .timedOut {
            throw SkytellsError(
                message: "Request timed out",
                errorId: "REQUEST_TIMEOUT",
                details: "The request took too long to complete",
                httpStatus: 408
            )
        } catch {
            throw SkytellsError(
                message: error.localizedDescription,
                errorId: "NETWORK_ERROR",
                details: "A network error occurred while communicating with the API"
            )
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SkytellsError(
                message: "Invalid response",
                errorId: "INVALID_RESPONSE",
                details: "The server returned a non-HTTP response"
            )
        }

        let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") ?? ""
        guard contentType.contains("application/json") else {
            let text = String(data: data.prefix(500), encoding: .utf8) ?? "Could not read response body"
            throw SkytellsError(
                message: "Server responded with non-JSON content (\(contentType))",
                errorId: "SERVER_ERROR",
                details: "Status: \(httpResponse.statusCode), Content: \(text)",
                httpStatus: httpResponse.statusCode
            )
        }

        // Try to decode as an API error first if the status code indicates failure
        if !(200...299).contains(httpResponse.statusCode) {
            throw try parseAPIError(data: data, statusCode: httpResponse.statusCode)
        }

        // Check for `"status": false` in the response (API-level error with 200 status)
        if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data),
           errorResponse.status == false {
            throw parseStructuredError(errorResponse, statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw SkytellsError(
                message: "Failed to decode response",
                errorId: "DECODE_ERROR",
                details: "Could not decode the server response: \(error.localizedDescription)",
                httpStatus: httpResponse.statusCode
            )
        }
    }

    private func parseAPIError(data: Data, statusCode: Int) throws -> SkytellsError {
        if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
            return parseStructuredError(errorResponse, statusCode: statusCode)
        }
        return SkytellsError(
            message: "HTTP error \(statusCode)",
            errorId: "HTTP_ERROR",
            details: "The server returned status code \(statusCode)",
            httpStatus: statusCode
        )
    }

    private func parseStructuredError(_ errorResponse: APIErrorResponse, statusCode: Int) -> SkytellsError {
        if let detail = errorResponse.error {
            return SkytellsError(
                message: detail.message ?? errorResponse.response ?? "API error occurred",
                errorId: detail.errorId ?? "UNKNOWN_ERROR",
                details: detail.details ?? errorResponse.response ?? "No additional details",
                httpStatus: detail.httpStatus ?? statusCode
            )
        }
        if let response = errorResponse.response {
            return SkytellsError(
                message: response,
                errorId: "API_ERROR",
                details: response,
                httpStatus: statusCode
            )
        }
        return SkytellsError(
            message: "HTTP error \(statusCode)",
            errorId: "HTTP_ERROR",
            details: "The server returned status code \(statusCode)",
            httpStatus: statusCode
        )
    }
}
