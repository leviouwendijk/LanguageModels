import Foundation
import FoundationModels

public struct TypedModelRunner<Returnable: ModelReturnable>: Sendable {
    public let instructions: ModelInstructions
    public let runner: ModelRunner

    public init(
        instructions: ModelInstructions,
    ) {
        self.instructions = instructions
        self.runner = ModelRunner(instructions: instructions)
    }

    public func execute() async throws -> Returnable {
        let raw = try await runner.execute()

        return try Returnable.parse(from: raw)
    }

    public func stream<Content: Decodable>(
        generating: Content.Type,
        includeSchemaInPrompt: Bool = false,
        options: GenerationOptions = GenerationOptions()
    ) throws -> LanguageModelSession.ResponseStream<Content> {
        let session = LanguageModelSession(model: .default, tools: [])
        return session.streamResponse(
            generating: generating,
            includeSchemaInPrompt: includeSchemaInPrompt,
            options: options
        ) {
            runner.prompt
        }
    }
}
