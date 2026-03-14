# Skytells Swift SDK

The official Skytells SDK for Swift — access Skytells AI services from iOS, macOS, tvOS, and watchOS.

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Xcode (recommended)

1. In Xcode, go to **File → Add Package Dependencies…**
2. Enter the repository URL:
   ```
   https://github.com/skytells-research/swift-sdk.git
   ```
3. Set the dependency rule to **Up to Next Major Version** starting from `1.0.0`.
4. Select the `Skytells` library product and add it to your target.

### Swift Package Manager

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/skytells-research/swift-sdk.git", from: "1.0.0")
]
```

Then add `Skytells` to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Skytells", package: "swift-sdk")
    ]
)
```

## Getting an API Key

To use the Skytells SDK, you need an API key.

API Key can be optained from [Skytells Dashboard](https://skytells.ai/dashboard/api-keys)

Visit [docs.skytells.ai](https://docs.skytells.ai) to create an account and obtain your API key.

## Usage

### Initialize the client

```swift
import Skytells

let client = SkytellsClient(apiKey: "sk-your-api-key")
// or
let client = Skytells.createClient(apiKey: "sk-your-api-key")
```

### Run a prediction

```swift
let prediction = try await client.predict(.init(
    model: "vendor/model-name",
    input: ["prompt": "A sunset over the ocean"],
    await: true
))

// Access output URLs
if let urls = prediction.outputURLs {
    print(urls)
}

// Or a single output URL
if let url = prediction.firstOutputURL {
    print(url)
}

// Text output
if let text = prediction.outputString {
    print(text)
}
```

### Get a prediction by ID

```swift
let prediction = try await client.getPrediction(id: "prediction-id")
```

### Cancel a prediction

```swift
let prediction = try await client.cancelPrediction(id: "prediction-id")
```

### Delete a prediction

```swift
let prediction = try await client.deletePrediction(id: "prediction-id")
```

### List available models

```swift
let models = try await client.listModels()
```

### Error handling

```swift
do {
    let prediction = try await client.predict(.init(
        model: "vendor/model",
        input: ["prompt": "test"]
    ))
} catch let error as SkytellsError {
    print("Error: \(error.message)")
    print("Error ID: \(error.errorId)")
    print("HTTP Status: \(error.httpStatus)")
}
```

## License

MIT — see [LICENSE](LICENSE) for details.
