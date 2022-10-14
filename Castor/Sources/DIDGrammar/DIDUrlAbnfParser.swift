// Generated from java-escape by ANTLR 4.11.1
import Antlr4

open class DIDUrlAbnfParser: Parser {

	internal static var _decisionToDFA: [DFA] = {
          var decisionToDFA = [DFA]()
          let length = DIDUrlAbnfParser._ATN.getNumberOfDecisions()
          for i in 0..<length {
            decisionToDFA.append(DFA(DIDUrlAbnfParser._ATN.getDecisionState(i)!, i))
           }
           return decisionToDFA
     }()

	internal static let _sharedContextCache = PredictionContextCache()

	public
	enum Tokens: Int {
		case EOF = -1, T__0 = 1, T__1 = 2, T__2 = 3, T__3 = 4, T__4 = 5, SCHEMA = 6, 
                 ALPHA = 7, DIGIT = 8, PCT_ENCODED = 9, PERCENT = 10, DASH = 11, 
                 PERIOD = 12, COLON = 13, UNDERSCORE = 14, HEX = 15, STRING = 16
	}

	public
	static let RULE_did_url = 0, RULE_did = 1, RULE_method_name = 2, RULE_method_specific_id = 3, 
            RULE_path = 4, RULE_query = 5, RULE_frag = 6, RULE_search = 7, 
            RULE_searchparameter = 8, RULE_string = 9

	public
	static let ruleNames: [String] = [
		"did_url", "did", "method_name", "method_specific_id", "path", "query", 
		"frag", "search", "searchparameter", "string"
	]

	private static let _LITERAL_NAMES: [String?] = [
		nil, "'/'", "'?'", "'#'", "'&'", "'='", nil, nil, nil, nil, "'%'", "'-'", 
		"'.'", "':'", "'_'"
	]
	private static let _SYMBOLIC_NAMES: [String?] = [
		nil, nil, nil, nil, nil, nil, "SCHEMA", "ALPHA", "DIGIT", "PCT_ENCODED", 
		"PERCENT", "DASH", "PERIOD", "COLON", "UNDERSCORE", "HEX", "STRING"
	]
	public
	static let VOCABULARY = Vocabulary(_LITERAL_NAMES, _SYMBOLIC_NAMES)

	override open
	func getGrammarFileName() -> String { return "java-escape" }

	override open
	func getRuleNames() -> [String] { return DIDUrlAbnfParser.ruleNames }

	override open
	func getSerializedATN() -> [Int] { return DIDUrlAbnfParser._serializedATN }

	override open
	func getATN() -> ATN { return DIDUrlAbnfParser._ATN }


	override open
	func getVocabulary() -> Vocabulary {
	    return DIDUrlAbnfParser.VOCABULARY
	}

	override public
	init(_ input:TokenStream) throws {
	    RuntimeMetaData.checkVersion("4.11.1", RuntimeMetaData.VERSION)
		try super.init(input)
		_interp = ParserATNSimulator(self,DIDUrlAbnfParser._ATN,DIDUrlAbnfParser._decisionToDFA, DIDUrlAbnfParser._sharedContextCache)
	}


	public class Did_urlContext: ParserRuleContext {
			open
			func did() -> DidContext? {
				return getRuleContext(DidContext.self, 0)
			}
			open
			func EOF() -> TerminalNode? {
				return getToken(DIDUrlAbnfParser.Tokens.EOF.rawValue, 0)
			}
			open
			func path() -> PathContext? {
				return getRuleContext(PathContext.self, 0)
			}
			open
			func query() -> QueryContext? {
				return getRuleContext(QueryContext.self, 0)
			}
			open
			func frag() -> FragContext? {
				return getRuleContext(FragContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return DIDUrlAbnfParser.RULE_did_url
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.enterDid_url(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.exitDid_url(self)
			}
		}
	}
	@discardableResult
	 open func did_url() throws -> Did_urlContext {
		var _localctx: Did_urlContext
		_localctx = Did_urlContext(_ctx, getState())
		try enterRule(_localctx, 0, DIDUrlAbnfParser.RULE_did_url)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(20)
		 	try did()
		 	setState(22)
		 	try _errHandler.sync(self)
		 	switch (try getInterpreter().adaptivePredict(_input,0,_ctx)) {
		 	case 1:
		 		setState(21)
		 		try path()

		 		break
		 	default: break
		 	}
		 	setState(25)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == DIDUrlAbnfParser.Tokens.T__1.rawValue) {
		 		setState(24)
		 		try query()

		 	}

		 	setState(28)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == DIDUrlAbnfParser.Tokens.T__2.rawValue) {
		 		setState(27)
		 		try frag()

		 	}

		 	setState(30)
		 	try match(DIDUrlAbnfParser.Tokens.EOF.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class DidContext: ParserRuleContext {
			open
			func SCHEMA() -> TerminalNode? {
				return getToken(DIDUrlAbnfParser.Tokens.SCHEMA.rawValue, 0)
			}
			open
			func COLON() -> [TerminalNode] {
				return getTokens(DIDUrlAbnfParser.Tokens.COLON.rawValue)
			}
			open
			func COLON(_ i:Int) -> TerminalNode? {
				return getToken(DIDUrlAbnfParser.Tokens.COLON.rawValue, i)
			}
			open
			func method_name() -> Method_nameContext? {
				return getRuleContext(Method_nameContext.self, 0)
			}
			open
			func method_specific_id() -> Method_specific_idContext? {
				return getRuleContext(Method_specific_idContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return DIDUrlAbnfParser.RULE_did
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.enterDid(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.exitDid(self)
			}
		}
	}
	@discardableResult
	 open func did() throws -> DidContext {
		var _localctx: DidContext
		_localctx = DidContext(_ctx, getState())
		try enterRule(_localctx, 2, DIDUrlAbnfParser.RULE_did)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(32)
		 	try match(DIDUrlAbnfParser.Tokens.SCHEMA.rawValue)
		 	setState(33)
		 	try match(DIDUrlAbnfParser.Tokens.COLON.rawValue)
		 	setState(34)
		 	try method_name()
		 	setState(35)
		 	try match(DIDUrlAbnfParser.Tokens.COLON.rawValue)
		 	setState(36)
		 	try method_specific_id()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class Method_nameContext: ParserRuleContext {
			open
			func string() -> StringContext? {
				return getRuleContext(StringContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return DIDUrlAbnfParser.RULE_method_name
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.enterMethod_name(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.exitMethod_name(self)
			}
		}
	}
	@discardableResult
	 open func method_name() throws -> Method_nameContext {
		var _localctx: Method_nameContext
		_localctx = Method_nameContext(_ctx, getState())
		try enterRule(_localctx, 4, DIDUrlAbnfParser.RULE_method_name)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(38)
		 	try string()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class Method_specific_idContext: ParserRuleContext {
			open
			func string() -> [StringContext] {
				return getRuleContexts(StringContext.self)
			}
			open
			func string(_ i: Int) -> StringContext? {
				return getRuleContext(StringContext.self, i)
			}
			open
			func COLON() -> [TerminalNode] {
				return getTokens(DIDUrlAbnfParser.Tokens.COLON.rawValue)
			}
			open
			func COLON(_ i:Int) -> TerminalNode? {
				return getToken(DIDUrlAbnfParser.Tokens.COLON.rawValue, i)
			}
		override open
		func getRuleIndex() -> Int {
			return DIDUrlAbnfParser.RULE_method_specific_id
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.enterMethod_specific_id(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.exitMethod_specific_id(self)
			}
		}
	}
	@discardableResult
	 open func method_specific_id() throws -> Method_specific_idContext {
		var _localctx: Method_specific_idContext
		_localctx = Method_specific_idContext(_ctx, getState())
		try enterRule(_localctx, 6, DIDUrlAbnfParser.RULE_method_specific_id)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt:Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(46)
		 	try _errHandler.sync(self)
		 	_alt = try getInterpreter().adaptivePredict(_input,4,_ctx)
		 	while (_alt != 2 && _alt != ATN.INVALID_ALT_NUMBER) {
		 		if ( _alt==1 ) {
		 			setState(40)
		 			try string()
		 			setState(42)
		 			try _errHandler.sync(self)
		 			_la = try _input.LA(1)
		 			if (_la == DIDUrlAbnfParser.Tokens.COLON.rawValue) {
		 				setState(41)
		 				try match(DIDUrlAbnfParser.Tokens.COLON.rawValue)

		 			}


		 	 
		 		}
		 		setState(48)
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input,4,_ctx)
		 	}
		 	setState(49)
		 	try string()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class PathContext: ParserRuleContext {
			open
			func string() -> [StringContext] {
				return getRuleContexts(StringContext.self)
			}
			open
			func string(_ i: Int) -> StringContext? {
				return getRuleContext(StringContext.self, i)
			}
		override open
		func getRuleIndex() -> Int {
			return DIDUrlAbnfParser.RULE_path
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.enterPath(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.exitPath(self)
			}
		}
	}
	@discardableResult
	 open func path() throws -> PathContext {
		var _localctx: PathContext
		_localctx = PathContext(_ctx, getState())
		try enterRule(_localctx, 8, DIDUrlAbnfParser.RULE_path)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt:Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(55)
		 	try _errHandler.sync(self)
		 	_alt = try getInterpreter().adaptivePredict(_input,5,_ctx)
		 	while (_alt != 2 && _alt != ATN.INVALID_ALT_NUMBER) {
		 		if ( _alt==1 ) {
		 			setState(51)
		 			try match(DIDUrlAbnfParser.Tokens.T__0.rawValue)
		 			setState(52)
		 			try string()

		 	 
		 		}
		 		setState(57)
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input,5,_ctx)
		 	}
		 	setState(59)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == DIDUrlAbnfParser.Tokens.T__0.rawValue) {
		 		setState(58)
		 		try match(DIDUrlAbnfParser.Tokens.T__0.rawValue)

		 	}


		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class QueryContext: ParserRuleContext {
			open
			func search() -> SearchContext? {
				return getRuleContext(SearchContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return DIDUrlAbnfParser.RULE_query
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.enterQuery(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.exitQuery(self)
			}
		}
	}
	@discardableResult
	 open func query() throws -> QueryContext {
		var _localctx: QueryContext
		_localctx = QueryContext(_ctx, getState())
		try enterRule(_localctx, 10, DIDUrlAbnfParser.RULE_query)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(61)
		 	try match(DIDUrlAbnfParser.Tokens.T__1.rawValue)
		 	setState(62)
		 	try search()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class FragContext: ParserRuleContext {
			open
			func string() -> StringContext? {
				return getRuleContext(StringContext.self, 0)
			}
			open
			func DIGIT() -> TerminalNode? {
				return getToken(DIDUrlAbnfParser.Tokens.DIGIT.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return DIDUrlAbnfParser.RULE_frag
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.enterFrag(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.exitFrag(self)
			}
		}
	}
	@discardableResult
	 open func frag() throws -> FragContext {
		var _localctx: FragContext
		_localctx = FragContext(_ctx, getState())
		try enterRule(_localctx, 12, DIDUrlAbnfParser.RULE_frag)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(64)
		 	try match(DIDUrlAbnfParser.Tokens.T__2.rawValue)
		 	setState(67)
		 	try _errHandler.sync(self)
		 	switch(try getInterpreter().adaptivePredict(_input,7, _ctx)) {
		 	case 1:
		 		setState(65)
		 		try string()

		 		break
		 	case 2:
		 		setState(66)
		 		try match(DIDUrlAbnfParser.Tokens.DIGIT.rawValue)

		 		break
		 	default: break
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SearchContext: ParserRuleContext {
			open
			func searchparameter() -> [SearchparameterContext] {
				return getRuleContexts(SearchparameterContext.self)
			}
			open
			func searchparameter(_ i: Int) -> SearchparameterContext? {
				return getRuleContext(SearchparameterContext.self, i)
			}
		override open
		func getRuleIndex() -> Int {
			return DIDUrlAbnfParser.RULE_search
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.enterSearch(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.exitSearch(self)
			}
		}
	}
	@discardableResult
	 open func search() throws -> SearchContext {
		var _localctx: SearchContext
		_localctx = SearchContext(_ctx, getState())
		try enterRule(_localctx, 14, DIDUrlAbnfParser.RULE_search)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(69)
		 	try searchparameter()
		 	setState(74)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (_la == DIDUrlAbnfParser.Tokens.T__3.rawValue) {
		 		setState(70)
		 		try match(DIDUrlAbnfParser.Tokens.T__3.rawValue)
		 		setState(71)
		 		try searchparameter()


		 		setState(76)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SearchparameterContext: ParserRuleContext {
			open
			func string() -> [StringContext] {
				return getRuleContexts(StringContext.self)
			}
			open
			func string(_ i: Int) -> StringContext? {
				return getRuleContext(StringContext.self, i)
			}
			open
			func DIGIT() -> TerminalNode? {
				return getToken(DIDUrlAbnfParser.Tokens.DIGIT.rawValue, 0)
			}
			open
			func HEX() -> TerminalNode? {
				return getToken(DIDUrlAbnfParser.Tokens.HEX.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return DIDUrlAbnfParser.RULE_searchparameter
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.enterSearchparameter(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.exitSearchparameter(self)
			}
		}
	}
	@discardableResult
	 open func searchparameter() throws -> SearchparameterContext {
		var _localctx: SearchparameterContext
		_localctx = SearchparameterContext(_ctx, getState())
		try enterRule(_localctx, 16, DIDUrlAbnfParser.RULE_searchparameter)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(77)
		 	try string()
		 	setState(84)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == DIDUrlAbnfParser.Tokens.T__4.rawValue) {
		 		setState(78)
		 		try match(DIDUrlAbnfParser.Tokens.T__4.rawValue)
		 		setState(82)
		 		try _errHandler.sync(self)
		 		switch(try getInterpreter().adaptivePredict(_input,9, _ctx)) {
		 		case 1:
		 			setState(79)
		 			try string()

		 			break
		 		case 2:
		 			setState(80)
		 			try match(DIDUrlAbnfParser.Tokens.DIGIT.rawValue)

		 			break
		 		case 3:
		 			setState(81)
		 			try match(DIDUrlAbnfParser.Tokens.HEX.rawValue)

		 			break
		 		default: break
		 		}

		 	}


		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class StringContext: ParserRuleContext {
			open
			func STRING() -> TerminalNode? {
				return getToken(DIDUrlAbnfParser.Tokens.STRING.rawValue, 0)
			}
			open
			func DIGIT() -> TerminalNode? {
				return getToken(DIDUrlAbnfParser.Tokens.DIGIT.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return DIDUrlAbnfParser.RULE_string
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.enterString(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? DIDUrlAbnfListener {
				listener.exitString(self)
			}
		}
	}
	@discardableResult
	 open func string() throws -> StringContext {
		var _localctx: StringContext
		_localctx = StringContext(_ctx, getState())
		try enterRule(_localctx, 18, DIDUrlAbnfParser.RULE_string)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(86)
		 	_la = try _input.LA(1)
		 	if (!(_la == DIDUrlAbnfParser.Tokens.DIGIT.rawValue || _la == DIDUrlAbnfParser.Tokens.STRING.rawValue)) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	static let _serializedATN:[Int] = [
		4,1,16,89,2,0,7,0,2,1,7,1,2,2,7,2,2,3,7,3,2,4,7,4,2,5,7,5,2,6,7,6,2,7,
		7,7,2,8,7,8,2,9,7,9,1,0,1,0,3,0,23,8,0,1,0,3,0,26,8,0,1,0,3,0,29,8,0,1,
		0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,2,1,3,1,3,3,3,43,8,3,5,3,45,8,3,10,
		3,12,3,48,9,3,1,3,1,3,1,4,1,4,5,4,54,8,4,10,4,12,4,57,9,4,1,4,3,4,60,8,
		4,1,5,1,5,1,5,1,6,1,6,1,6,3,6,68,8,6,1,7,1,7,1,7,5,7,73,8,7,10,7,12,7,
		76,9,7,1,8,1,8,1,8,1,8,1,8,3,8,83,8,8,3,8,85,8,8,1,9,1,9,1,9,0,0,10,0,
		2,4,6,8,10,12,14,16,18,0,1,2,0,8,8,16,16,90,0,20,1,0,0,0,2,32,1,0,0,0,
		4,38,1,0,0,0,6,46,1,0,0,0,8,55,1,0,0,0,10,61,1,0,0,0,12,64,1,0,0,0,14,
		69,1,0,0,0,16,77,1,0,0,0,18,86,1,0,0,0,20,22,3,2,1,0,21,23,3,8,4,0,22,
		21,1,0,0,0,22,23,1,0,0,0,23,25,1,0,0,0,24,26,3,10,5,0,25,24,1,0,0,0,25,
		26,1,0,0,0,26,28,1,0,0,0,27,29,3,12,6,0,28,27,1,0,0,0,28,29,1,0,0,0,29,
		30,1,0,0,0,30,31,5,0,0,1,31,1,1,0,0,0,32,33,5,6,0,0,33,34,5,13,0,0,34,
		35,3,4,2,0,35,36,5,13,0,0,36,37,3,6,3,0,37,3,1,0,0,0,38,39,3,18,9,0,39,
		5,1,0,0,0,40,42,3,18,9,0,41,43,5,13,0,0,42,41,1,0,0,0,42,43,1,0,0,0,43,
		45,1,0,0,0,44,40,1,0,0,0,45,48,1,0,0,0,46,44,1,0,0,0,46,47,1,0,0,0,47,
		49,1,0,0,0,48,46,1,0,0,0,49,50,3,18,9,0,50,7,1,0,0,0,51,52,5,1,0,0,52,
		54,3,18,9,0,53,51,1,0,0,0,54,57,1,0,0,0,55,53,1,0,0,0,55,56,1,0,0,0,56,
		59,1,0,0,0,57,55,1,0,0,0,58,60,5,1,0,0,59,58,1,0,0,0,59,60,1,0,0,0,60,
		9,1,0,0,0,61,62,5,2,0,0,62,63,3,14,7,0,63,11,1,0,0,0,64,67,5,3,0,0,65,
		68,3,18,9,0,66,68,5,8,0,0,67,65,1,0,0,0,67,66,1,0,0,0,68,13,1,0,0,0,69,
		74,3,16,8,0,70,71,5,4,0,0,71,73,3,16,8,0,72,70,1,0,0,0,73,76,1,0,0,0,74,
		72,1,0,0,0,74,75,1,0,0,0,75,15,1,0,0,0,76,74,1,0,0,0,77,84,3,18,9,0,78,
		82,5,5,0,0,79,83,3,18,9,0,80,83,5,8,0,0,81,83,5,15,0,0,82,79,1,0,0,0,82,
		80,1,0,0,0,82,81,1,0,0,0,83,85,1,0,0,0,84,78,1,0,0,0,84,85,1,0,0,0,85,
		17,1,0,0,0,86,87,7,0,0,0,87,19,1,0,0,0,11,22,25,28,42,46,55,59,67,74,82,
		84
	]

	public
	static let _ATN = try! ATNDeserializer().deserialize(_serializedATN)
}