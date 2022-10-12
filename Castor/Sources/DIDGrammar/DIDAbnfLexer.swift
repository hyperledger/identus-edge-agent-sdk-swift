// Generated from java-escape by ANTLR 4.11.1
import Antlr4

open class DIDAbnfLexer: Lexer {

	internal static var _decisionToDFA: [DFA] = {
          var decisionToDFA = [DFA]()
          let length = DIDAbnfLexer._ATN.getNumberOfDecisions()
          for i in 0..<length {
          	    decisionToDFA.append(DFA(DIDAbnfLexer._ATN.getDecisionState(i)!, i))
          }
           return decisionToDFA
     }()

	internal static let _sharedContextCache = PredictionContextCache()

	public
	static let SCHEMA=1, ALPHA=2, DIGIT=3, PCT_ENCODED=4, PERCENT=5, DASH=6, 
            PERIOD=7, COLON=8, UNDERSCORE=9

	public
	static let channelNames: [String] = [
		"DEFAULT_TOKEN_CHANNEL", "HIDDEN"
	]

	public
	static let modeNames: [String] = [
		"DEFAULT_MODE"
	]

	public
	static let ruleNames: [String] = [
		"D", "I", "SCHEMA", "LOWERCASE", "UPPERCASE", "ALPHA", "HEX", "DIGIT", 
		"PCT_ENCODED", "PERCENT", "DASH", "PERIOD", "COLON", "UNDERSCORE"
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
	func getVocabulary() -> Vocabulary {
		return DIDAbnfLexer.VOCABULARY
	}

	public
	required init(_ input: CharStream) {
	    RuntimeMetaData.checkVersion("4.11.1", RuntimeMetaData.VERSION)
		super.init(input)
		_interp = LexerATNSimulator(self, DIDAbnfLexer._ATN, DIDAbnfLexer._decisionToDFA, DIDAbnfLexer._sharedContextCache)
	}

	override open
	func getGrammarFileName() -> String { return "DIDAbnf.g4" }

	override open
	func getRuleNames() -> [String] { return DIDAbnfLexer.ruleNames }

	override open
	func getSerializedATN() -> [Int] { return DIDAbnfLexer._serializedATN }

	override open
	func getChannelNames() -> [String] { return DIDAbnfLexer.channelNames }

	override open
	func getModeNames() -> [String] { return DIDAbnfLexer.modeNames }

	override open
	func getATN() -> ATN { return DIDAbnfLexer._ATN }

	static let _serializedATN:[Int] = [
		4,0,9,63,6,-1,2,0,7,0,2,1,7,1,2,2,7,2,2,3,7,3,2,4,7,4,2,5,7,5,2,6,7,6,
		2,7,7,7,2,8,7,8,2,9,7,9,2,10,7,10,2,11,7,11,2,12,7,12,2,13,7,13,1,0,1,
		0,1,1,1,1,1,2,1,2,1,2,1,2,1,3,1,3,1,4,1,4,1,5,1,5,3,5,44,8,5,1,6,1,6,1,
		7,1,7,1,8,1,8,1,8,1,8,1,9,1,9,1,10,1,10,1,11,1,11,1,12,1,12,1,13,1,13,
		0,0,14,1,0,3,0,5,1,7,0,9,0,11,2,13,0,15,3,17,4,19,5,21,6,23,7,25,8,27,
		9,1,0,6,2,0,68,68,100,100,2,0,73,73,105,105,1,0,97,122,1,0,65,90,3,0,48,
		57,65,70,97,102,1,0,48,57,58,0,5,1,0,0,0,0,11,1,0,0,0,0,15,1,0,0,0,0,17,
		1,0,0,0,0,19,1,0,0,0,0,21,1,0,0,0,0,23,1,0,0,0,0,25,1,0,0,0,0,27,1,0,0,
		0,1,29,1,0,0,0,3,31,1,0,0,0,5,33,1,0,0,0,7,37,1,0,0,0,9,39,1,0,0,0,11,
		43,1,0,0,0,13,45,1,0,0,0,15,47,1,0,0,0,17,49,1,0,0,0,19,53,1,0,0,0,21,
		55,1,0,0,0,23,57,1,0,0,0,25,59,1,0,0,0,27,61,1,0,0,0,29,30,7,0,0,0,30,
		2,1,0,0,0,31,32,7,1,0,0,32,4,1,0,0,0,33,34,3,1,0,0,34,35,3,3,1,0,35,36,
		3,1,0,0,36,6,1,0,0,0,37,38,7,2,0,0,38,8,1,0,0,0,39,40,7,3,0,0,40,10,1,
		0,0,0,41,44,3,7,3,0,42,44,3,9,4,0,43,41,1,0,0,0,43,42,1,0,0,0,44,12,1,
		0,0,0,45,46,7,4,0,0,46,14,1,0,0,0,47,48,7,5,0,0,48,16,1,0,0,0,49,50,3,
		19,9,0,50,51,3,13,6,0,51,52,3,13,6,0,52,18,1,0,0,0,53,54,5,37,0,0,54,20,
		1,0,0,0,55,56,5,45,0,0,56,22,1,0,0,0,57,58,5,46,0,0,58,24,1,0,0,0,59,60,
		5,58,0,0,60,26,1,0,0,0,61,62,5,95,0,0,62,28,1,0,0,0,2,0,43,0
	]

	public
	static let _ATN: ATN = try! ATNDeserializer().deserialize(_serializedATN)
}