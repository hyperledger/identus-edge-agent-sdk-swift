// Generated from java-escape by ANTLR 4.11.1
import Antlr4

open class DIDAbnfParser: Parser {
    internal static var _decisionToDFA: [DFA] = {
        var decisionToDFA = [DFA]()
        let length = DIDAbnfParser._ATN.getNumberOfDecisions()
        for i in 0 ..< length {
            decisionToDFA.append(DFA(DIDAbnfParser._ATN.getDecisionState(i)!, i))
        }
        return decisionToDFA
    }()

    internal static let _sharedContextCache = PredictionContextCache()

    public
    enum Tokens: Int {
        case EOF = -1, SCHEMA = 1, ALPHA = 2, DIGIT = 3, PCT_ENCODED = 4, PERCENT = 5,
             DASH = 6, PERIOD = 7, COLON = 8, UNDERSCORE = 9
    }

    public
    static let RULE_did = 0, RULE_method_name = 1, RULE_method_specific_id = 2,
               RULE_idchar = 3

    public
    static let ruleNames: [String] = [
        "did", "method_name", "method_specific_id", "idchar"
    ]

    private static let _LITERAL_NAMES: [String?] = [
        nil, nil, nil, nil, nil, "'%'", "'-'", "'.'", "':'", "'_'"
    ]
    private static let _SYMBOLIC_NAMES: [String?] = [
        nil, "SCHEMA", "ALPHA", "DIGIT", "PCT_ENCODED", "PERCENT", "DASH", "PERIOD",
        "COLON", "UNDERSCORE"
    ]
    public
    static let VOCABULARY = Vocabulary(_LITERAL_NAMES, _SYMBOLIC_NAMES)

    override open
    func getGrammarFileName() -> String { return "java-escape" }

    override open
    func getRuleNames() -> [String] { return DIDAbnfParser.ruleNames }

    override open
    func getSerializedATN() -> [Int] { return DIDAbnfParser._serializedATN }

    override open
    func getATN() -> ATN { return DIDAbnfParser._ATN }

    override open
    func getVocabulary() -> Vocabulary {
        return DIDAbnfParser.VOCABULARY
    }

    override public
    init(_ input: TokenStream) throws {
        RuntimeMetaData.checkVersion("4.11.1", RuntimeMetaData.VERSION)
        try super.init(input)
        _interp = ParserATNSimulator(self, DIDAbnfParser._ATN, DIDAbnfParser._decisionToDFA, DIDAbnfParser._sharedContextCache)
    }

    public class DidContext: ParserRuleContext {
        open
        func SCHEMA() -> TerminalNode? {
            return getToken(DIDAbnfParser.Tokens.SCHEMA.rawValue, 0)
        }

        open
        func COLON() -> [TerminalNode] {
            return getTokens(DIDAbnfParser.Tokens.COLON.rawValue)
        }

        open
        func COLON(_ i: Int) -> TerminalNode? {
            return getToken(DIDAbnfParser.Tokens.COLON.rawValue, i)
        }

        open
        func method_name() -> Method_nameContext? {
            return getRuleContext(Method_nameContext.self, 0)
        }

        open
        func method_specific_id() -> Method_specific_idContext? {
            return getRuleContext(Method_specific_idContext.self, 0)
        }

        open
        func EOF() -> TerminalNode? {
            return getToken(DIDAbnfParser.Tokens.EOF.rawValue, 0)
        }

        override open
        func getRuleIndex() -> Int {
            return DIDAbnfParser.RULE_did
        }

        override open
        func enterRule(_ listener: ParseTreeListener) {
            if let listener = listener as? DIDAbnfListener {
                listener.enterDid(self)
            }
        }

        override open
        func exitRule(_ listener: ParseTreeListener) {
            if let listener = listener as? DIDAbnfListener {
                listener.exitDid(self)
            }
        }
    }

    @discardableResult
    open func did() throws -> DidContext {
        var _localctx: DidContext
        _localctx = DidContext(_ctx, getState())
        try enterRule(_localctx, 0, DIDAbnfParser.RULE_did)
        defer {
            try! exitRule()
        }
        do {
            try enterOuterAlt(_localctx, 1)
            setState(8)
            try match(DIDAbnfParser.Tokens.SCHEMA.rawValue)
            setState(9)
            try match(DIDAbnfParser.Tokens.COLON.rawValue)
            setState(10)
            try method_name()
            setState(11)
            try match(DIDAbnfParser.Tokens.COLON.rawValue)
            setState(12)
            try method_specific_id()
            setState(13)
            try match(DIDAbnfParser.Tokens.EOF.rawValue)
        } catch let ANTLRException.recognition(re) {
            _localctx.exception = re
            _errHandler.reportError(self, re)
            try _errHandler.recover(self, re)
        }

        return _localctx
    }

    public class Method_nameContext: ParserRuleContext {
        open
        func ALPHA() -> [TerminalNode] {
            return getTokens(DIDAbnfParser.Tokens.ALPHA.rawValue)
        }

        open
        func ALPHA(_ i: Int) -> TerminalNode? {
            return getToken(DIDAbnfParser.Tokens.ALPHA.rawValue, i)
        }

        open
        func DIGIT() -> [TerminalNode] {
            return getTokens(DIDAbnfParser.Tokens.DIGIT.rawValue)
        }

        open
        func DIGIT(_ i: Int) -> TerminalNode? {
            return getToken(DIDAbnfParser.Tokens.DIGIT.rawValue, i)
        }

        override open
        func getRuleIndex() -> Int {
            return DIDAbnfParser.RULE_method_name
        }

        override open
        func enterRule(_ listener: ParseTreeListener) {
            if let listener = listener as? DIDAbnfListener {
                listener.enterMethod_name(self)
            }
        }

        override open
        func exitRule(_ listener: ParseTreeListener) {
            if let listener = listener as? DIDAbnfListener {
                listener.exitMethod_name(self)
            }
        }
    }

    @discardableResult
    open func method_name() throws -> Method_nameContext {
        var _localctx: Method_nameContext
        _localctx = Method_nameContext(_ctx, getState())
        try enterRule(_localctx, 2, DIDAbnfParser.RULE_method_name)
        var _la = 0
        defer {
            try! exitRule()
        }
        do {
            try enterOuterAlt(_localctx, 1)
            setState(16)
            try _errHandler.sync(self)
            _la = try _input.LA(1)
            repeat {
                setState(15)
                _la = try _input.LA(1)
                if !(_la == DIDAbnfParser.Tokens.ALPHA.rawValue || _la == DIDAbnfParser.Tokens.DIGIT.rawValue) {
                    try _errHandler.recoverInline(self)
                } else {
                    _errHandler.reportMatch(self)
                    try consume()
                }

                setState(18)
                try _errHandler.sync(self)
                _la = try _input.LA(1)
            } while _la == DIDAbnfParser.Tokens.ALPHA.rawValue || _la == DIDAbnfParser.Tokens.DIGIT.rawValue
        } catch let ANTLRException.recognition(re) {
            _localctx.exception = re
            _errHandler.reportError(self, re)
            try _errHandler.recover(self, re)
        }

        return _localctx
    }

    public class Method_specific_idContext: ParserRuleContext {
        open
        func COLON() -> [TerminalNode] {
            return getTokens(DIDAbnfParser.Tokens.COLON.rawValue)
        }

        open
        func COLON(_ i: Int) -> TerminalNode? {
            return getToken(DIDAbnfParser.Tokens.COLON.rawValue, i)
        }

        open
        func idchar() -> [IdcharContext] {
            return getRuleContexts(IdcharContext.self)
        }

        open
        func idchar(_ i: Int) -> IdcharContext? {
            return getRuleContext(IdcharContext.self, i)
        }

        override open
        func getRuleIndex() -> Int {
            return DIDAbnfParser.RULE_method_specific_id
        }

        override open
        func enterRule(_ listener: ParseTreeListener) {
            if let listener = listener as? DIDAbnfListener {
                listener.enterMethod_specific_id(self)
            }
        }

        override open
        func exitRule(_ listener: ParseTreeListener) {
            if let listener = listener as? DIDAbnfListener {
                listener.exitMethod_specific_id(self)
            }
        }
    }

    @discardableResult
    open func method_specific_id() throws -> Method_specific_idContext {
        var _localctx: Method_specific_idContext
        _localctx = Method_specific_idContext(_ctx, getState())
        try enterRule(_localctx, 4, DIDAbnfParser.RULE_method_specific_id)
        var _la = 0
        defer {
            try! exitRule()
        }
        do {
            var _alt: Int
            try enterOuterAlt(_localctx, 1)
            setState(29)
            try _errHandler.sync(self)
            _alt = try getInterpreter().adaptivePredict(_input, 2, _ctx)
            while _alt != 2, _alt != ATN.INVALID_ALT_NUMBER {
                if _alt == 1 {
                    setState(21)
                    try _errHandler.sync(self)
                    _la = try _input.LA(1)
                    repeat {
                        setState(20)
                        try idchar()

                        setState(23)
                        try _errHandler.sync(self)
                        _la = try _input.LA(1)
                    } while (Int64(_la) & ~0x3F) == 0 && ((Int64(1) << _la) & 732) != 0
                    setState(25)
                    try match(DIDAbnfParser.Tokens.COLON.rawValue)
                }
                setState(31)
                try _errHandler.sync(self)
                _alt = try getInterpreter().adaptivePredict(_input, 2, _ctx)
            }
            setState(33)
            try _errHandler.sync(self)
            _la = try _input.LA(1)
            repeat {
                setState(32)
                try idchar()

                setState(35)
                try _errHandler.sync(self)
                _la = try _input.LA(1)
            } while (Int64(_la) & ~0x3F) == 0 && ((Int64(1) << _la) & 732) != 0
        } catch let ANTLRException.recognition(re) {
            _localctx.exception = re
            _errHandler.reportError(self, re)
            try _errHandler.recover(self, re)
        }

        return _localctx
    }

    public class IdcharContext: ParserRuleContext {
        open
        func ALPHA() -> TerminalNode? {
            return getToken(DIDAbnfParser.Tokens.ALPHA.rawValue, 0)
        }

        open
        func DIGIT() -> TerminalNode? {
            return getToken(DIDAbnfParser.Tokens.DIGIT.rawValue, 0)
        }

        open
        func PERIOD() -> TerminalNode? {
            return getToken(DIDAbnfParser.Tokens.PERIOD.rawValue, 0)
        }

        open
        func DASH() -> TerminalNode? {
            return getToken(DIDAbnfParser.Tokens.DASH.rawValue, 0)
        }

        open
        func UNDERSCORE() -> TerminalNode? {
            return getToken(DIDAbnfParser.Tokens.UNDERSCORE.rawValue, 0)
        }

        open
        func PCT_ENCODED() -> TerminalNode? {
            return getToken(DIDAbnfParser.Tokens.PCT_ENCODED.rawValue, 0)
        }

        override open
        func getRuleIndex() -> Int {
            return DIDAbnfParser.RULE_idchar
        }

        override open
        func enterRule(_ listener: ParseTreeListener) {
            if let listener = listener as? DIDAbnfListener {
                listener.enterIdchar(self)
            }
        }

        override open
        func exitRule(_ listener: ParseTreeListener) {
            if let listener = listener as? DIDAbnfListener {
                listener.exitIdchar(self)
            }
        }
    }

    @discardableResult
    open func idchar() throws -> IdcharContext {
        var _localctx: IdcharContext
        _localctx = IdcharContext(_ctx, getState())
        try enterRule(_localctx, 6, DIDAbnfParser.RULE_idchar)
        var _la = 0
        defer {
            try! exitRule()
        }
        do {
            try enterOuterAlt(_localctx, 1)
            setState(37)
            _la = try _input.LA(1)
            if !((Int64(_la) & ~0x3F) == 0 && ((Int64(1) << _la) & 732) != 0) {
                try _errHandler.recoverInline(self)
            } else {
                _errHandler.reportMatch(self)
                try consume()
            }
        } catch let ANTLRException.recognition(re) {
            _localctx.exception = re
            _errHandler.reportError(self, re)
            try _errHandler.recover(self, re)
        }

        return _localctx
    }

    static let _serializedATN: [Int] = [
        4, 1, 9, 40, 2, 0, 7, 0, 2, 1, 7, 1, 2, 2, 7, 2, 2, 3, 7, 3, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
        1, 4, 1, 17, 8, 1, 11, 1, 12, 1, 18, 1, 2, 4, 2, 22, 8, 2, 11, 2, 12, 2, 23, 1, 2, 1, 2, 5, 2, 28, 8,
        2, 10, 2, 12, 2, 31, 9, 2, 1, 2, 4, 2, 34, 8, 2, 11, 2, 12, 2, 35, 1, 3, 1, 3, 1, 3, 0, 0, 4, 0, 2, 4,
        6, 0, 2, 1, 0, 2, 3, 3, 0, 2, 4, 6, 7, 9, 9, 39, 0, 8, 1, 0, 0, 0, 2, 16, 1, 0, 0, 0, 4, 29, 1, 0, 0, 0,
        6, 37, 1, 0, 0, 0, 8, 9, 5, 1, 0, 0, 9, 10, 5, 8, 0, 0, 10, 11, 3, 2, 1, 0, 11, 12, 5, 8, 0, 0, 12, 13,
        3, 4, 2, 0, 13, 14, 5, 0, 0, 1, 14, 1, 1, 0, 0, 0, 15, 17, 7, 0, 0, 0, 16, 15, 1, 0, 0, 0, 17, 18, 1,
        0, 0, 0, 18, 16, 1, 0, 0, 0, 18, 19, 1, 0, 0, 0, 19, 3, 1, 0, 0, 0, 20, 22, 3, 6, 3, 0, 21, 20, 1, 0,
        0, 0, 22, 23, 1, 0, 0, 0, 23, 21, 1, 0, 0, 0, 23, 24, 1, 0, 0, 0, 24, 25, 1, 0, 0, 0, 25, 26, 5, 8,
        0, 0, 26, 28, 1, 0, 0, 0, 27, 21, 1, 0, 0, 0, 28, 31, 1, 0, 0, 0, 29, 27, 1, 0, 0, 0, 29, 30, 1, 0,
        0, 0, 30, 33, 1, 0, 0, 0, 31, 29, 1, 0, 0, 0, 32, 34, 3, 6, 3, 0, 33, 32, 1, 0, 0, 0, 34, 35, 1, 0,
        0, 0, 35, 33, 1, 0, 0, 0, 35, 36, 1, 0, 0, 0, 36, 5, 1, 0, 0, 0, 37, 38, 7, 1, 0, 0, 38, 7, 1, 0, 0,
        0, 4, 18, 23, 29, 35
    ]

    public
    static let _ATN = try! ATNDeserializer().deserialize(_serializedATN)
}
