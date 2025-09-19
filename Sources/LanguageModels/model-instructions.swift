import Foundation

public struct ModelInstructions: Sendable {
    public let precontext: String?
    public let instructions: String
    
    public init(
        precontext: String? = nil,
        instructions: String
    ) {
        self.precontext = precontext
        self.instructions = instructions
    }
    
    public func prompt() -> String {
        return """
        <context>
        \(precontext ?? "")

        <instructions>
        \(instructions)
        """
    }
}
