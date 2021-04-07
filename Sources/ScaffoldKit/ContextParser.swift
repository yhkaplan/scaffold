import Parser

enum ContextParser {
    static func parseContextArgument(_ string: String) throws -> [String: Any] {
        return try keyValueDictParser(string).match
    }
}

// sample text: name=search,type=swiftui,author=$USER
fileprivate let validCharacterParser = substring(while: {
    switch $0 {
    case "=", ",": return false
    default: return true
    }
})
.map(String.init)

fileprivate let keyValueParser = zip(
    validCharacterParser,
    removingLiteral("="),
    oneOf([
        arrayValueParser.map { $0 as Any },
        validCharacterParser.map { $0 as Any }
    ])
).map { key, _, value in [key: value] }

fileprivate let keyValueDictParser = zeroOrMore(keyValueParser, separatedBy: removingLiteral(",")).map { keyValues in
    return Dictionary(uniqueKeysWithValues: keyValues.flatMap { $0 })
}

/// to support nesting like `name=search,outputs=[name=buttonIsEnabled,type=Driver<Bool>]`
/// - Note: This only permits single-depth, non-recursive lists like above, not lists containing more lists
fileprivate let arrayValueParser = zip(
    removingLiteral("["),
    zeroOrMore(
        zip(validCharacterParser, removingLiteral("="), validCharacterParser),
        separatedBy: removingLiteral(",")
    ),
    removingLiteral("]")
).map { (_: Void, contents: [(String, Void, String)], _: Void) -> [[String: Any]]  in
    contents.map { (key, _, value) in [key: value] }
}
