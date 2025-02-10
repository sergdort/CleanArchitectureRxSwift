import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct InvertedDependency: Macro {
    public func expand(
        declaration: DeclSyntax,
        context: MacroExpansionContext
    ) throws -> DeclSyntax {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            throw DependencyKeyMacroErrors.shouldBeAttachedToAProtocol
        }
        
        // Retrieve the protocol name
        let protocolName = protocolDecl.name.text

        // Generate the dependency key enum and unimplemented struct
        let enumCode = """
        enum \(protocolName)DependencyKey: TestDependencyKey {
            struct Unimplemented: \(protocolName) {
                \(protocolDecl.memberBlock.members.compactMap { member -> String? in
                    guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else { return nil }
                    let funcName = funcDecl.name.text
                    let returnType = funcDecl.signature.returnClause?.description ?? ""
                    let isThrowing = funcDecl.signature.effectSpecifiers?.throwsClause != nil
                    let throwsAttribute = isThrowing ? "throws" : ""
                    return "func \(funcName)\(funcDecl.signature.parameterClause) \(throwsAttribute)\(returnType) { unimplemented(#function) }"
                }
                .joined(separator: "\n"))
            }
        
            static var testValue: \(protocolName) {
                Unimplemented()
            }
        }
        """

        // Generate the DependencyValues extension
        let extensionCode = """
        public extension DependencyValues {
            var \(protocolName.firstLowercased()): \(protocolName) {
                get { self[\(protocolName)DependencyKey.self] }
                set { self[\(protocolName)DependencyKey.self] = newValue }
            }
        }
        """

        return DeclSyntax(stringLiteral: "\(enumCode)\n\n\(extensionCode)")
    }
}

fileprivate extension String {
    /// Returns the string with the first character lowercased, for naming conventions.
    func firstLowercased() -> String {
        return prefix(1).lowercased() + dropFirst()
    }
}

struct TextMessage: DiagnosticMessage {
    var message: String
    
    var diagnosticID: SwiftDiagnostics.MessageID
    
    var severity: SwiftDiagnostics.DiagnosticSeverity
}

enum DependencyKeyMacroErrors: Error {
    case shouldBeAttachedToAProtocol
}
