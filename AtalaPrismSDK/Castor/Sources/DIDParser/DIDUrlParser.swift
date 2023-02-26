import Antlr4
import Domain
import Foundation

struct DIDUrlParser {
    let didUrlString: String

    func parse() throws -> DIDUrl {
        let inputStream = ANTLRInputStream(didUrlString)
        let lexer = DIDUrlAbnfLexer(inputStream)
        let tokenStream = CommonTokenStream(lexer)

        let parser = try DIDUrlAbnfParser(tokenStream)
        parser.setErrorHandler(BailErrorStrategy())
        let context = try parser.did_url()

        let listener = Listener()
        try ParseTreeWalker().walk(listener, context)

        guard
            let schema = listener.scheme,
            let methodName = listener.methodName,
            let methodId = listener.methodId
        else { throw CastorError.invalidDIDString(didUrlString) }

        let did = DID(
            schema: schema,
            method: methodName,
            methodId: methodId
        )

        let didUrl = DIDUrl(
            did: did,
            path: listener.path ?? [],
            parameters: listener.query,
            fragment: listener.fragment
        )

        return didUrl
    }
}

private final class Listener: DIDUrlAbnfBaseListener {
    fileprivate var scheme: String?
    fileprivate var methodName: String?
    fileprivate var methodId: String?
    fileprivate var path: [String]?
    fileprivate var query = [String: String]()
    fileprivate var fragment: String?

    override func exitDid(_ ctx: DIDUrlAbnfParser.DidContext) {
        ctx.SCHEMA().map { scheme = $0.getText() }
    }

    override func exitMethod_name(_ ctx: DIDUrlAbnfParser.Method_nameContext) {
        methodName = ctx.getText()
    }

    override func exitMethod_specific_id(
        _ ctx: DIDUrlAbnfParser.Method_specific_idContext
    ) {
        methodId = ctx.getText()
    }

    override func exitPath(_ ctx: DIDUrlAbnfParser.PathContext) {
        guard !ctx.isEmpty() else { return }
        path = ctx.string().map { $0.getText() }
    }

    override func exitFrag(_ ctx: DIDUrlAbnfParser.FragContext) {
        guard !ctx.isEmpty() else { return }
        fragment = ctx.string()?.getText() ?? ctx.DIGIT()?.getText()
    }

    override func exitSearchparameter(_ ctx: DIDUrlAbnfParser.SearchparameterContext) {
        guard
            !ctx.isEmpty(),
            let key = ctx.string(0)?.getText(),
            let value = ctx.string(1)?.getText()
        else { return }
        query[key] = value
    }
}
