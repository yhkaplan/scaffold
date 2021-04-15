public struct Parser<A> {
    public let run: (inout Substring) throws -> A

    public init(run: @escaping (inout Substring) throws -> A) {
        self.run = run
    }
}

public extension Parser {

    func callAsFunction(_ str: String) throws -> (match: A, rest: Substring) {
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
public func zip<A, B>(_ a: Parser<A>, _ b: Parser<B>) -> Parser<(A, B)> {
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
public func zip<A, B, C>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>
) -> Parser<(A, B, C)> {
    return zip(a, zip(b, c))
        .map { a, bc in (a, bc.0, bc.1) }
}

public enum ParserError: Error {
    case never, unexpectedEnd, noneFound

    public enum StringError: Error {
        case literalNotFound(Substring)
    }
}

public func removingLiteral(_ string: String) -> Parser<Void> {
    return Parser<Void> { input in
        guard input.hasPrefix(string) else { throw ParserError.StringError.literalNotFound(string[...]) }
        input.removeFirst(string.count)
    }
}

// 1 or more
public func substring(while predicate: @escaping (Character) -> Bool) -> Parser<Substring> {
    return Parser<Substring> { input in
        let p = input.prefix(while: predicate)
        input.removeFirst(p.count)

        return p
    }
}

public func zeroOrMore<A>(_ p: Parser<A>, separatedBy s: Parser<Void>) -> Parser<[A]> {
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

public func oneOf<A>(_ ps: [Parser<A>]) -> Parser<A> {
    return Parser<A> { str -> A in
        for p in ps {
            if let match = (try? p.run(&str)) {
                return match
            }
        }
        throw ParserError.noneFound
    }
}
