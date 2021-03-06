[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

_Works with **Swift 2.0** (Xcode 7). Here is the [Swift 1.2 version] (https://github.com/kareman/FootlessParser/tree/v0.1.4)._

# FootlessParser

FootlessParser is a simple and pretty naive implementation of a parser combinator in Swift. It enables infinite lookahead, non-ambiguous parsing with error reporting.

There is [a series of blog posts about the development](http://blog.nottoobadsoftware.com/footlessparser/) and [documentation from the source code](http://kareman.github.io/FootlessParser/).

### Introduction

In short, FootlessParser lets you define parsers like this:

```swift
let parser = function1 <^> parser1 <*> parser2 <|> parser3
```

`function1` and `parser3` return the same type.

`parser` will pass the input to `parser1` followed by `parser2`, pass their results to `function1` and return its result. If that fails it will pass the original input to `parser3` and return its result.

### Definitions

##### Parser
A function which takes some input (a sequence of tokens) and returns either the output and the remaining unparsed part of the input, or an error description if it fails.

##### Token
A single item from the input. Like a character from a string, an element from an array or a string from a list of command line arguments.

##### Parser Input
Most often text, but can also be an array or really any collection of anything, provided it conforms to CollectionType.

### Parsers

The general idea is to combine very simple parsers into more complex ones. So `char("a")`  creates a parser which checks if the next token from the input is an “a”. If it is it returns that “a”, otherwise it returns an error. You can then use operators and functions like `zeroOrMore` and `optional` to create ever more complex parsers. For more check out [the full list of functions](http://kareman.github.io/FootlessParser/Functions.html).

### Operators

##### <^> (map)

`function <^> parser1` creates a new parser which runs parser1. If it succeeds it passes the output to `function` and returns the result.

##### <*> (apply)

`function <^> parser1 <*> parser2` creates a new parser which first runs parser1. If it succeeds it runs parser2. If that also succeeds it passes both outputs to `function` and returns the result.

The <*> operator requires its left parser to return a function and is normally used together with <^>. `function` must take 2 parameters of the correct types, and it must be [curried](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Declarations.html#//apple_ref/doc/uid/TP40014097-CH34-ID363), like this:

```swift
func function (a:A)(b:B) -> C 
```

This is because <*> returns the output of 2 parsers and it doesn't know what to do with them. If you want them returned in a tuple, an array or e.g. added together you can do so in the function before <^> .

If there are 3 parsers and 2 <*> the function must take 3 parameters, and so on.

##### <* 

The same as the <*> above, except it discards the result of the parser to its right. Since it only returns one output it doesn't need to be used together with <^> . But you can of course if you want the output converted to something else.

##### *>

The same as <* , but discards the result of the parser to its left.

##### <|> (choice)

```
parser1 <|> parser2 <|> parser3
```

This operator tries all the parsers in order and returns the result of the first one that succeeds.

##### >>- (flatmap)

```
parser1 >>- ( o -> parser2 )
```

This does the same as the flatmap functions in the Swift Standard Library. It creates a new parser which first tries parser1. If it fails it returns the error, if it succeeds it passes the output to the function which uses it to create parser2. It then runs parser2 and returns its output or error.

### Example

#### [CSV](http://www.computerhope.com/jargon/c/csv.htm) parser

```swift
let delimiter = "," as Character
let quote = "\"" as Character
let newline = "\n" as Character

let cell = char(quote) *> zeroOrMore(not(quote)) <* char(quote)
	<|> zeroOrMore(noneOf([delimiter, newline]))

let row = extend <^> cell <*> zeroOrMore( char(delimiter) *> cell ) <* char(newline)
let csvparser = zeroOrMore(row)
```

Here a cell (or field) either:

- begins with a ", then contains anything, including commas, tabs and newlines, and ends with a " (both quotes are discarded) 
- or is unquoted and contains anything but a comma or a newline.

Each row then consists of one or more cells, separated by commas and ended by a newline. The `extend` function joins the cells together into an array. 
Finally the `csvparser` collects zero or more rows into an array.

To perform the actual parsing:

```swift
do {
	let output = try parse(csvparser, csvtext)
	// output is an array of all the rows, 
	// where each row is an array of all its cells.
} catch {

}
```

### Installation

#### Using [Carthage](https://github.com/Carthage/Carthage)

```
github "kareman/FootlessParser"
```

Then run `carthage update`.

Follow the current instructions in [Carthage's README][carthage-installation] for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application
