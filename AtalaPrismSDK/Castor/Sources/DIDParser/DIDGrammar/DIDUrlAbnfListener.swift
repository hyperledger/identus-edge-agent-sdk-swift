// Generated from DIDUrlAbnf.g4 by ANTLR 4.12.0
import Antlr4

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link DIDUrlAbnfParser}.
 */
public protocol DIDUrlAbnfListener: ParseTreeListener {
	/**
	 * Enter a parse tree produced by {@link DIDUrlAbnfParser#did_url}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterDid_url(_ ctx: DIDUrlAbnfParser.Did_urlContext)
	/**
	 * Exit a parse tree produced by {@link DIDUrlAbnfParser#did_url}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitDid_url(_ ctx: DIDUrlAbnfParser.Did_urlContext)
	/**
	 * Enter a parse tree produced by {@link DIDUrlAbnfParser#did}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterDid(_ ctx: DIDUrlAbnfParser.DidContext)
	/**
	 * Exit a parse tree produced by {@link DIDUrlAbnfParser#did}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitDid(_ ctx: DIDUrlAbnfParser.DidContext)
	/**
	 * Enter a parse tree produced by {@link DIDUrlAbnfParser#method_name}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterMethod_name(_ ctx: DIDUrlAbnfParser.Method_nameContext)
	/**
	 * Exit a parse tree produced by {@link DIDUrlAbnfParser#method_name}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitMethod_name(_ ctx: DIDUrlAbnfParser.Method_nameContext)
	/**
	 * Enter a parse tree produced by {@link DIDUrlAbnfParser#method_specific_id}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterMethod_specific_id(_ ctx: DIDUrlAbnfParser.Method_specific_idContext)
	/**
	 * Exit a parse tree produced by {@link DIDUrlAbnfParser#method_specific_id}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitMethod_specific_id(_ ctx: DIDUrlAbnfParser.Method_specific_idContext)
	/**
	 * Enter a parse tree produced by {@link DIDUrlAbnfParser#path}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterPath(_ ctx: DIDUrlAbnfParser.PathContext)
	/**
	 * Exit a parse tree produced by {@link DIDUrlAbnfParser#path}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitPath(_ ctx: DIDUrlAbnfParser.PathContext)
	/**
	 * Enter a parse tree produced by {@link DIDUrlAbnfParser#query}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterQuery(_ ctx: DIDUrlAbnfParser.QueryContext)
	/**
	 * Exit a parse tree produced by {@link DIDUrlAbnfParser#query}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitQuery(_ ctx: DIDUrlAbnfParser.QueryContext)
	/**
	 * Enter a parse tree produced by {@link DIDUrlAbnfParser#frag}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterFrag(_ ctx: DIDUrlAbnfParser.FragContext)
	/**
	 * Exit a parse tree produced by {@link DIDUrlAbnfParser#frag}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitFrag(_ ctx: DIDUrlAbnfParser.FragContext)
	/**
	 * Enter a parse tree produced by {@link DIDUrlAbnfParser#search}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSearch(_ ctx: DIDUrlAbnfParser.SearchContext)
	/**
	 * Exit a parse tree produced by {@link DIDUrlAbnfParser#search}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSearch(_ ctx: DIDUrlAbnfParser.SearchContext)
	/**
	 * Enter a parse tree produced by {@link DIDUrlAbnfParser#searchparameter}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSearchparameter(_ ctx: DIDUrlAbnfParser.SearchparameterContext)
	/**
	 * Exit a parse tree produced by {@link DIDUrlAbnfParser#searchparameter}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSearchparameter(_ ctx: DIDUrlAbnfParser.SearchparameterContext)
	/**
	 * Enter a parse tree produced by {@link DIDUrlAbnfParser#string}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterString(_ ctx: DIDUrlAbnfParser.StringContext)
	/**
	 * Exit a parse tree produced by {@link DIDUrlAbnfParser#string}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitString(_ ctx: DIDUrlAbnfParser.StringContext)
}