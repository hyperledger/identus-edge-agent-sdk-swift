import Antlr4
import Domain
import Foundation

struct DIDParser {
    struct InvalidDIDStringError: Error {}

    let didString: String

    func parse() throws -> DID {
        let inputStream = ANTLRInputStream(didString)
        let lexer = DIDAbnfLexer(inputStream)
        let tokenStream = CommonTokenStream(lexer)

        let parser = try DIDAbnfParser(tokenStream)
        parser.setErrorHandler(BailErrorStrategy())
        let context = try parser.did()

        let listener = Listener()
        try ParseTreeWalker().walk(listener, context)

        guard
            let schema = listener.scheme,
            let methodName = listener.methodName,
            let methodId = listener.methodId
        else { throw InvalidDIDStringError() }

        let did = DID(
            schema: schema,
            method: methodName,
            methodId: methodId
        )

        return did
    }
}

private final class Listener: DIDAbnfBaseListener {
    fileprivate var scheme: String?
    fileprivate var methodName: String?
    fileprivate var methodId: String?

    override func exitDid(_ ctx: DIDAbnfParser.DidContext) {
        ctx.SCHEMA().map { scheme = $0.getText() }
    }

    override func exitMethod_name(_ ctx: DIDAbnfParser.Method_nameContext) {
        methodName = ctx.getText()
    }

    override func exitMethod_specific_id(
        _ ctx: DIDAbnfParser.Method_specific_idContext
    ) {
        methodId = ctx.getText()
    }
}
