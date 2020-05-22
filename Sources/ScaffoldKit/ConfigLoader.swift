import Foundation
import PathKit
import Yams

protocol ConfigLoadable {
    func loadConfig(at path: String) throws -> ScaffoldConfig
}

struct ConfigLoader: ConfigLoadable {
    func loadConfig(at path: String) throws -> ScaffoldConfig {
        let configFile: String = try Path(path).read()
        let config = try YAMLDecoder().decode(ScaffoldConfig.self, from: configFile)

        return config
    }
}
