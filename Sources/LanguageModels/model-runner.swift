import Foundation
import FoundationModels

public struct ModelRunner: Sendable {
    public let instructions: ModelInstructions

    public var prompt: String {
        instructions.prompt()
    }

    public init(
        instructions: ModelInstructions,
    ) {
        self.instructions = instructions
    }

    public func execute() async throws -> String {
        let session = LanguageModelSession(
            model: .default,
            tools: []
        )

        // try await session.prewarm(promptPrefix: instructions.precontext)
        // let response = try await session.respond(to: instructions.instructions)

        let response = try await session.respond(to: prompt)
        let generated = response.content.trimmingCharacters(in: .whitespacesAndNewlines)

        return generated
    }
}

public struct TypedModelRunner<Returnable: ModelReturnable>: Sendable {
    public let instructions: ModelInstructions

    public init(
        instructions: ModelInstructions,
    ) {
        self.instructions = instructions
    }

    public func execute() async throws -> Returnable {
        let runner = ModelRunner(instructions: instructions)
        let raw = try await runner.execute()

        return try Returnable.parse(from: raw)
    }
}
