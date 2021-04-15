import Foundation
import PathKit
import Yams

enum ConfigLoader {
    static func loadConfig(at path: String) throws -> ScaffoldConfig {
        let configFile: String = try Path(path).read()
        let config = try YAMLDecoder().decode(ScaffoldConfig.self, from: configFile)

        return config
    }
}
