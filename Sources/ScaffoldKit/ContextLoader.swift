import Foundation
import PathKit

enum ContextLoader {
    static func loadContextFile(at path: String) throws -> [String: Any] {
        let data = try Path(path).read()
        guard let context = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw ScaffoldError.contextFileCouldNotBeDecoded
        }
        return context
    }
}
