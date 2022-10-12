// Generated from java-escape by ANTLR 4.11.1
import Antlr4

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link DIDAbnfParser}.
 */
public protocol DIDAbnfListener: ParseTreeListener {
	/**
	 * Enter a parse tree produced by {@link DIDAbnfParser#did}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterDid(_ ctx: DIDAbnfParser.DidContext)
	/**
	 * Exit a parse tree produced by {@link DIDAbnfParser#did}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitDid(_ ctx: DIDAbnfParser.DidContext)
	/**
	 * Enter a parse tree produced by {@link DIDAbnfParser#method_name}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterMethod_name(_ ctx: DIDAbnfParser.Method_nameContext)
	/**
	 * Exit a parse tree produced by {@link DIDAbnfParser#method_name}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitMethod_name(_ ctx: DIDAbnfParser.Method_nameContext)
	/**
	 * Enter a parse tree produced by {@link DIDAbnfParser#method_specific_id}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterMethod_specific_id(_ ctx: DIDAbnfParser.Method_specific_idContext)
	/**
	 * Exit a parse tree produced by {@link DIDAbnfParser#method_specific_id}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitMethod_specific_id(_ ctx: DIDAbnfParser.Method_specific_idContext)
	/**
	 * Enter a parse tree produced by {@link DIDAbnfParser#idchar}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterIdchar(_ ctx: DIDAbnfParser.IdcharContext)
	/**
	 * Exit a parse tree produced by {@link DIDAbnfParser#idchar}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitIdchar(_ ctx: DIDAbnfParser.IdcharContext)
}