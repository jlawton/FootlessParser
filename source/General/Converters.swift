//
// Converters.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

/** Return a collection containing x and all elements of xs. Works with strings and arrays. */
public func extend
	<A, C: RangeReplaceableCollectionType where C.Generator.Element == A>
	(x: A)(xs: C) -> C {

	// not satisfied with this way of doing it, but RangeReplaceableCollectionType has only mutable methods.
	var result = C()
	result.append(x)
	result.appendContentsOf(xs)
	return result
}

/** Join 2 collections together. */
public func extend
	<C1: RangeReplaceableCollectionType, C2: CollectionType where C1.Generator.Element == C2.Generator.Element>
	(var xs1: C1)(xs2: C2) -> C1 {

	xs1.appendContentsOf(xs2)
	return xs1
}

/** Create a tuple of the arguments. */
public func tuple <A,B> (a: A)(b: B) -> (A,B) {
	return (a, b)
}
