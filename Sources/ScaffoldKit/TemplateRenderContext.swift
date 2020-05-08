//
//  TemplateRenderContext.swift
//  ArgumentParser
//
//  Created by josh on 2020/05/08.
//

struct TemplateRenderContext {
    let context: [String: Any]?

    init(name: String?, context: String?) throws {
        if let name = name {
            self.context = ["name": name]
        } else if let context = context {
            self.context = try keyValueDictParser.run(context).match
        } else {
            self.context = nil
        }
    }
}

// TODO: move all the below into separate framework
struct Parser<A> {
    let run: (inout Substring) throws -> A
}

extension Parser {
    // TODO: try out callAsFunction when updating to Swift 5.2
    // ref: https://www.donnywals.com/how-and-when-to-use-callasfunction-in-swift-5-2/
    // `func callAsFunction(_ str: String) throws -> (match: A, rest: Substring)`
    func run(_ str: String) throws -> (match: A, rest: Substring) {
        var input = str[...]
        let match = try self.run(&input)
        return (match, input)
    }

    func map<B>(_ f: @escaping (A) throws -> B) rethrows -> Parser<B> {
        return Parser<B> { input throws -> B in
            try f(self.run(&input))
        }
    }
}
/// zip2
func zip<A, B>(_ a: Parser<A>, _ b: Parser<B>) -> Parser<(A, B)> {
    return Parser<(A, B)> { input throws -> (A, B) in
        let original = input
        let matchA = try a.run(&input)

        do {
            let matchB = try b.run(&input)
            return (matchA, matchB)

        } catch {
            input = original
            throw error
        }
    }
}

/// zip3
func zip<A, B, C>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>
) -> Parser<(A, B, C)> {
    return zip(a, zip(b, c))
        .map { a, bc in (a, bc.0, bc.1) }
}

enum ParserError: Error {
    case never, unexpectedEnd, noneFound

    enum StringError: Error {
        case literalNotFound(Substring)
    }
}
func removingLiteral(_ string: String) -> Parser<Void> {
    return Parser<Void> { input in
        guard input.hasPrefix(string) else { throw ParserError.StringError.literalNotFound(string[...]) }
        input.removeFirst(string.count)
    }
}

// 1 or more
func substring(while predicate: @escaping (Character) -> Bool) -> Parser<Substring> {
    return Parser<Substring> { input in
        let p = input.prefix(while: predicate)
        input.removeFirst(p.count)

        return p
    }
}

func zeroOrMore<A>(
  _ p: Parser<A>,
  separatedBy s: Parser<Void>
) -> Parser<[A]> {
  return Parser<[A]> { str in
    var rest = str
    var matches: [A] = []
    while let match = try? p.run(&str) {
      rest = str
      matches.append(match)
      if (try? s.run(&str)) == nil {
        return matches
      }
    }
    str = rest
    return matches
  }
}

func oneOf<A>(
  _ ps: [Parser<A>]
  ) -> Parser<A> {
  return Parser<A> { str -> A in
    for p in ps {
      if let match = (try? p.run(&str)) {
        return match
      }
    }
    throw ParserError.noneFound
  }
}

// sample text: name=search,type=swiftui,author=$USER
let validCharacterParser = substring(while: { $0.isLetter || $0.isNumber || ($0.isSymbol && $0 != "=") }).map(String.init)

let keyValueParser = zip(
    validCharacterParser,
    removingLiteral("="),
    oneOf([
        arrayValueParser.map { $0 as Any },
        validCharacterParser.map { $0 as Any }
    ])
).map { key, _, value in [key: value] }

let keyValueDictParser = zeroOrMore(keyValueParser, separatedBy: removingLiteral(",")).map { keyValues in
    return Dictionary(uniqueKeysWithValues: keyValues.flatMap { $0 })
}

/// to support nesting like `name=search,outputs=[name=buttonIsEnabled,type=Driver<Bool>]`
/// - Note: This only permits single depth, non-recursive lists like above, not lists containing more lists
let arrayValueParser = zip(
    removingLiteral("["),
    zeroOrMore(
        zip(validCharacterParser, removingLiteral("="), validCharacterParser),
        separatedBy: removingLiteral(",")
    ),
    removingLiteral("]")
).map { (_: Void, contents: [(String, Void, String)], _: Void) -> [[String: Any]]  in
    contents.map { (key, _, value) in [key: value] }
}
