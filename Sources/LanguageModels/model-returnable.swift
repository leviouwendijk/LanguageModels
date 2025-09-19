import Foundation

public enum ModelReturnableError: Error, LocalizedError {
    case extractionFailed(output: String)
    case decodingFailed(output: String, underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .extractionFailed:
            return "No JSON block could be extracted from the model output."
        case .decodingFailed:
            return "Failed to decode JSON into the expected structure."
        }
    }

    public var failureReason: String? {
        switch self {
        case .extractionFailed(let output):
            return "The model output did not contain a valid JSON block.\nOutput:\n\(output)"
        case .decodingFailed(let output, let underlying):
            return """
            The JSON block could not be parsed into the expected type.
            Output:\n\(output)\n
            Underlying error: \(underlying.localizedDescription)
            """
        }
    }
}

public protocol ModelReturnable: Decodable {
    static func parse(from string: String) throws -> Self
}

public extension ModelReturnable {
    static func extractJSONBlock(from text: String) -> Data? {
        guard let start = text.firstIndex(of: "{"),
              let end = text.lastIndex(of: "}") else {
            return nil
        }
        let jsonSubstring = text[start...end]
        return Data(jsonSubstring.utf8)
    }

    static func parse(from string: String) throws -> Self {
        guard let jsonData = extractJSONBlock(from: string) else {
            throw ModelReturnableError.extractionFailed(output: string)
        }

        do {
            return try JSONDecoder().decode(Self.self, from: jsonData)
        } catch {
            throw ModelReturnableError.decodingFailed(output: string, underlying: error)
        }
    }
}
