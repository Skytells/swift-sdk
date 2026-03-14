@testable import Skytells
import XCTest

final class SkytellsTests: XCTestCase {

    func testVersion() {
        XCTAssertEqual(Skytells.version, "1.0.0")
    }

    func testCreateClient() {
        let client = Skytells.createClient(apiKey: "sk-test")
        XCTAssertNotNil(client)
    }

    func testCreateClientWithOptions() {
        let client = SkytellsClient(apiKey: "sk-test", options: .init(baseURL: "https://custom.api", timeout: 30))
        XCTAssertNotNil(client)
    }

    // MARK: - Prediction decoding

    func testDecodePredictionWithURLArrayOutput() throws {
        let json = """
        {
          "id": "00000000-0000-0000-0000-000000000001",
          "status": "succeeded",
          "stream": false,
          "type": "inference",
          "input": { "prompt": "A test prompt" },
          "output": [
            "https://example.com/output/image.png"
          ],
          "created_at": "2026-01-01T00:00:00.000000Z",
          "started_at": "2026-01-01T00:00:00+00:00",
          "completed_at": "2026-01-01T00:00:01+00:00",
          "updated_at": "2026-01-01T00:00:01.000000Z",
          "privacy": "private",
          "source": "web",
          "model": { "name": "test-model", "type": "image" },
          "webhook": { "url": null, "events": [] },
          "metrics": {
            "image_count": 1,
            "predict_time": 10.5,
            "total_time": 10.5,
            "asset_count": 1
          },
          "metadata": {
            "billing": { "credits_used": 0.02 },
            "storage": {
              "files": [
                { "name": "file.png", "type": "image/png", "size": 1024, "url": "https://example.com/output/image.png" }
              ]
            },
            "data_available": true
          },
          "urls": {
            "get": "https://api.example.com/v1/predictions/00000000-0000-0000-0000-000000000001",
            "cancel": "https://api.example.com/v1/predictions/00000000-0000-0000-0000-000000000001/cancel",
            "stream": "https://api.example.com/v1/predictions/00000000-0000-0000-0000-000000000001/stream",
            "delete": "https://api.example.com/v1/predictions/00000000-0000-0000-0000-000000000001/delete"
          }
        }
        """

        let data = Data(json.utf8)
        let prediction = try JSONDecoder().decode(PredictionResponse.self, from: data)

        XCTAssertEqual(prediction.id, "00000000-0000-0000-0000-000000000001")
        XCTAssertEqual(prediction.status, .succeeded)
        XCTAssertEqual(prediction.type, .inference)
        XCTAssertFalse(prediction.stream)
        XCTAssertEqual(prediction.privacy, "private")
        XCTAssertEqual(prediction.source, .web)
        XCTAssertEqual(prediction.model?.name, "test-model")
        XCTAssertEqual(prediction.model?.type, "image")
        XCTAssertNil(prediction.webhook?.url)
        XCTAssertEqual(prediction.metrics?.imageCount, 1)
        XCTAssertEqual(prediction.metrics?.assetCount, 1)
        XCTAssertNotNil(prediction.metrics?.predictTime)
        XCTAssertNotNil(prediction.metrics?.totalTime)
        XCTAssertEqual(prediction.metadata?.dataAvailable, true)
        XCTAssertEqual(prediction.metadata?.billing?.creditsUsed, 0.02)
        XCTAssertEqual(prediction.metadata?.storage?.files?.count, 1)

        // Convenience accessors
        XCTAssertEqual(prediction.outputURLs?.count, 1)
        XCTAssertEqual(prediction.firstOutputURL, "https://example.com/output/image.png")
        XCTAssertNil(prediction.outputString)
    }

    func testDecodePredictionWithAudioOutput() throws {
        let json = """
        {
          "id": "00000000-0000-0000-0000-000000000002",
          "status": "succeeded",
          "stream": false,
          "type": "inference",
          "input": { "lyrics": "test lyrics", "prompt": "test genre" },
          "output": [
            "https://example.com/output/audio.mp3"
          ],
          "created_at": "2026-01-01T00:00:00.000000Z",
          "started_at": "2026-01-01T00:00:00.000000Z",
          "completed_at": "2026-01-01T00:00:48.000000Z",
          "updated_at": "2026-01-01T00:00:48.000000Z",
          "privacy": "private",
          "source": "api",
          "model": { "name": "test-audio-model", "type": "audio" },
          "webhook": { "url": null, "events": [] },
          "metrics": {
            "predict_time": 48.0,
            "total_time": 48.1
          },
          "metadata": {
            "billing": { "credits_used": 0.75 },
            "storage": {
              "files": [
                { "name": "output.mp3", "type": "application/octet-stream", "size": 2048, "url": "https://example.com/output/audio.mp3" }
              ]
            },
            "data_available": true
          },
          "urls": {
            "get": "https://api.example.com/v1/predictions/00000000-0000-0000-0000-000000000002",
            "cancel": "https://api.example.com/v1/predictions/00000000-0000-0000-0000-000000000002/cancel",
            "stream": "https://api.example.com/v1/predictions/00000000-0000-0000-0000-000000000002/stream",
            "delete": "https://api.example.com/v1/predictions/00000000-0000-0000-0000-000000000002/delete"
          }
        }
        """

        let data = Data(json.utf8)
        let prediction = try JSONDecoder().decode(PredictionResponse.self, from: data)

        XCTAssertEqual(prediction.id, "00000000-0000-0000-0000-000000000002")
        XCTAssertEqual(prediction.status, .succeeded)
        XCTAssertEqual(prediction.model?.type, "audio")
        XCTAssertNil(prediction.response)
        XCTAssertEqual(prediction.firstOutputURL, "https://example.com/output/audio.mp3")
        XCTAssertEqual(prediction.metadata?.billing?.creditsUsed, 0.75)
        XCTAssertNil(prediction.metrics?.imageCount)
        XCTAssertNil(prediction.metrics?.assetCount)
    }

    func testDecodePredictionWithStringOutput() throws {
        let json = """
        {
          "id": "abc123",
          "status": "succeeded",
          "stream": false,
          "type": "inference",
          "input": { "text": "hello" },
          "output": "Generated text result",
          "created_at": "2026-03-04T21:20:58.000000Z",
          "updated_at": "2026-03-04T21:20:59.000000Z",
          "privacy": "private"
        }
        """

        let data = Data(json.utf8)
        let prediction = try JSONDecoder().decode(PredictionResponse.self, from: data)

        XCTAssertEqual(prediction.outputString, "Generated text result")
        XCTAssertNil(prediction.outputURLs)
        XCTAssertNil(prediction.firstOutputURL)
    }

    func testDecodePredictionWithNullOutput() throws {
        let json = """
        {
          "id": "pending123",
          "status": "pending",
          "stream": false,
          "type": "inference",
          "input": { "prompt": "test" },
          "output": null,
          "created_at": "2026-03-04T21:20:58.000000Z",
          "updated_at": "2026-03-04T21:20:59.000000Z",
          "privacy": "private"
        }
        """

        let data = Data(json.utf8)
        let prediction = try JSONDecoder().decode(PredictionResponse.self, from: data)

        XCTAssertEqual(prediction.status, .pending)
        XCTAssertNil(prediction.startedAt)
        XCTAssertNil(prediction.completedAt)
        XCTAssertNil(prediction.firstOutputURL)
        XCTAssertNil(prediction.outputString)
    }

    func testDecodePredictionWithMissingOutput() throws {
        let json = """
        {
          "id": "no-output",
          "status": "processing",
          "stream": false,
          "type": "inference",
          "input": {},
          "created_at": "2026-03-04T21:20:58.000000Z",
          "updated_at": "2026-03-04T21:20:59.000000Z",
          "privacy": "private"
        }
        """

        let data = Data(json.utf8)
        let prediction = try JSONDecoder().decode(PredictionResponse.self, from: data)

        XCTAssertNil(prediction.output)
    }

    // MARK: - SkytellsError

    func testSkytellsError() {
        let error = SkytellsError(message: "Not found", errorId: "NOT_FOUND", details: "Resource missing", httpStatus: 404)
        XCTAssertEqual(error.httpStatus, 404)
        XCTAssertEqual(error.errorId, "NOT_FOUND")
        XCTAssertTrue(error.description.contains("NOT_FOUND"))
    }

    // MARK: - AnyCodableValue

    func testAnyCodableValueLiterals() {
        let str: AnyCodableValue = "hello"
        let num: AnyCodableValue = 42
        let dbl: AnyCodableValue = 3.14
        let flag: AnyCodableValue = true
        let null: AnyCodableValue = nil

        if case .string(let v) = str { XCTAssertEqual(v, "hello") } else { XCTFail() }
        if case .int(let v) = num { XCTAssertEqual(v, 42) } else { XCTFail() }
        if case .double(let v) = dbl { XCTAssertEqual(v, 3.14) } else { XCTFail() }
        if case .bool(let v) = flag { XCTAssertTrue(v) } else { XCTFail() }
        if case .null = null { } else { XCTFail() }
    }

    func testAnyCodableValueRoundTrip() throws {
        let original: AnyCodableValue = .dictionary([
            "key": .string("value"),
            "count": .int(5),
            "nested": .array([.bool(true), .null])
        ])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AnyCodableValue.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    // MARK: - PredictionRequest encoding

    func testPredictionRequestEncoding() throws {
        let request = PredictionRequest(
            model: "vendor/model",
            input: ["prompt": "A sunset", "steps": 20],
            await: true
        )
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertEqual(dict?["model"] as? String, "vendor/model")
        XCTAssertEqual(dict?["await"] as? Bool, true)
        XCTAssertNil(dict?["webhook"])
        XCTAssertNil(dict?["stream"])

        let input = dict?["input"] as? [String: Any]
        XCTAssertEqual(input?["prompt"] as? String, "A sunset")
        XCTAssertEqual(input?["steps"] as? Int, 20)
    }
}
