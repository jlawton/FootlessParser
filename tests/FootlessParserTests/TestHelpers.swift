//
// TestHelpers.swift
// FootlessParser
//
// Created by Kåre Morstøl on 09.04.15.
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import FootlessParser
import Result
import XCTest

public func == <T:Equatable, U:Equatable> (lhs: (output:T, nextinput:U), rhs: (output:T, nextinput:U)) -> Bool {
	return lhs.output == rhs.output && lhs.nextinput == rhs.nextinput
}

public func == <R:Equatable, I:Equatable, E:Equatable>
	(lhs: Result<(output:R, nextinput:I), E>, rhs: Result<(output:R, nextinput:I), E>) -> Bool {

	if let leftvalue = lhs.value, rightvalue = rhs.value where leftvalue == rightvalue {
		return true
	} else if let lefterror = lhs.error, righterror = rhs.error where lefterror == righterror {
		return true
	}
	return false
}

public func != <R:Equatable, I:Equatable, E:Equatable>
	(lhs: Result<(output:R, nextinput:I), E>, rhs: Result<(output:R, nextinput:I), E>) -> Bool {

	return !(lhs == rhs)
}

extension XCTestCase {

	/**
	Verifies that 2 parsers return the same given the same input, whether it be success or failure.

	- parameter shouldSucceed?: Optionally verifies success or failure.
	*/
	func assertParsesEqually <T, R: Equatable> ( p1: Parser<T,R>, _ p2: Parser<T,R>, input: [T], shouldSucceed: Bool? = nil, file: String = __FILE__, line: UInt = __LINE__) {

		let i = ParserInput(input)
		let (r1, r2) = (p1.parse(i), p2.parse(i))
		if r1 != r2 {
			XCTFail("with input '\(input)': '\(r1)' != '\(r2)", file: file, line: line)
		}
		if let shouldSucceed = shouldSucceed {
			if shouldSucceed && (r1.value == nil) {
				XCTFail("parsing of '\(input)' failed, shoud have succeeded", file: file, line: line)
			}
			if !shouldSucceed && (r1.error == nil) {
				XCTFail("parsing of '\(input)' succeeded, shoud have failed", file: file, line: line)
			}
		}
	}

	/** Verifies the parse succeeds, and optionally checks the result and how many tokens were consumed. Updates the provided 'input' parameter to the remaining input. */
	func assertParseSucceeds <T, R: Equatable>
		(p: Parser<T,R>, inout _ input: ParserInput<T>, result: R? = nil, consumed: Int? = nil, file: String = __FILE__, line: UInt = __LINE__) {

		p.parse(input).analysis(
			ifSuccess: { o, i in
				if let result = result {
					if o != result {
						XCTFail("with input '\(input)': output should be '\(result)', was '\(o)'. ", file: file, line: line)
					}
				}
				if let consumed = consumed {
					let actuallyconsumed = i.position() - input.position()
					if actuallyconsumed != consumed {
						XCTFail("should have consumed \(consumed), took \(actuallyconsumed)", file: file, line: line)
					}
				}
				input = i
			},
			ifFailure: { XCTFail("with input \(input): \($0)", file: file, line: line) }
		)
	}

	/** Verifies the parse succeeds, and optionally checks the result and how many tokens were consumed. Updates the provided 'input' parameter to the remaining input. */
	func assertParseSucceeds <T, R: Equatable>
		(p: Parser<T,[R]>, inout _ input: ParserInput<T>, result: [R]? = nil, consumed: Int? = nil, file: String = __FILE__, line: UInt = __LINE__) {

		p.parse(input).analysis(
			ifSuccess: { o, i in
				if let result = result {
					if o != result {
						XCTFail("with input '\(input)': output should be '\(result)', was '\(o)'. ", file: file, line: line)
					}
				}
				if let consumed = consumed {
					let actuallyconsumed = i.position() - input.position()
					if actuallyconsumed != consumed {
						XCTFail("should have consumed \(consumed), took \(actuallyconsumed)", file: file, line: line)
					}
				}
				input = i
			},
			ifFailure: { XCTFail("with input \(input): \($0)", file: file, line: line) }
		)
	}

	/** Verifies the parse succeeds, and optionally checks the result and how many tokens were consumed. */
	func assertParseSucceeds <T, R: Equatable, C: CollectionType where C.Generator.Element == T>
		(p: Parser<T,R>, _ input: C, result: R? = nil, consumed: Int? = nil, file: String = __FILE__, line: UInt = __LINE__) {

		var parserinput = ParserInput(input)
		assertParseSucceeds(p, &parserinput, result: result, consumed: consumed, file: file, line: line)
	}

	/** Verifies parsing the string succeeds, and optionally checks the result and how many tokens were consumed. */
	func assertParseSucceeds <R: Equatable>
		(p: Parser<Character,R>, _ input: String, result: R? = nil, consumed: Int? = nil, file: String = __FILE__, line: UInt = __LINE__) {

			var parserinput = ParserInput(input.characters)
			assertParseSucceeds(p, &parserinput, result: result, consumed: consumed, file: file, line: line)
	}

	/** Verifies the parse succeeds, and optionally checks the result and how many tokens were consumed. */
	func assertParseSucceeds <T, R: Equatable, C: CollectionType where C.Generator.Element == T>
		(p: Parser<T,[R]>, _ input: C, result: [R]? = nil, consumed: Int? = nil, file: String = __FILE__, line: UInt = __LINE__) {

		var parserinput = ParserInput(input)
		assertParseSucceeds(p, &parserinput, result: result, consumed: consumed, file: file, line: line)
	}


	/** Verifies the parse fails with the given input. */
	func assertParseFails <T, R>
		(p: Parser<T,R>, _ input: ParserInput<T>, file: String = __FILE__, line: UInt = __LINE__) {

		p.parse(input).analysis(
			ifSuccess: { XCTFail("Parsing succeeded with output '\($0.output)', should have failed.", file: file, line: line) },
			ifFailure: { if $0.message.isEmpty { XCTFail("Should have an error message", file: file, line: line) } }
		)
	}

	/** Verifies the parse fails with the given collection as input. */
	func assertParseFails <T, R, C: CollectionType where C.Generator.Element == T>
		(p: Parser<T,R>, _ input: C, file: String = __FILE__, line: UInt = __LINE__) {

		assertParseFails(p, ParserInput(input), file: file, line: line)
	}

	/** Verifies the parse fails with the given string as input. */
	func assertParseFails <R>
		(p: Parser<Character,R>, _ input: String, file: String = __FILE__, line: UInt = __LINE__) {

		return assertParseFails(p, input.characters)
	}
}


import Foundation

extension XCTestCase {

	func pathForTestResource (filename: String, type: String) -> String {
		let path = NSBundle(forClass: self.dynamicType).pathForResource(filename, ofType: type)
		assert(path != nil, "resource \(filename).\(type) not found")

		return path!
	}

	// from https://forums.developer.apple.com/thread/5824
	func XCTempAssertThrowsError (message: String = "", file: String = __FILE__, line: UInt = __LINE__, _ block: () throws -> ()) {
		do	{
			try block()

			let msg = (message == "") ? "Tested block did not throw error as expected." : message
			XCTFail(msg, file: file, line: line)
		} catch {}
	}

	func XCTempAssertNoThrowError(message: String = "", file: String = __FILE__, line: UInt = __LINE__, _ block: () throws -> ()) {
		do { try block() }
		catch	{
			let msg = (message == "") ? "Tested block threw unexpected error: " : message
			XCTFail(msg + String(error), file: file, line: line)
		}
	}
}
