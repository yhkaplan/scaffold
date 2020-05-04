//
//  ConfigReader.swift
//  ArgumentParser
//
//  Created by josh on 2020/05/04.
//

import Foundation
import PathKit
import Yams

protocol ConfigLoadable {
    func loadConfig(at path: String) throws -> Config
}

struct ConfigLoader: ConfigLoadable {
    func loadConfig(at path: String) throws -> Config {
        let configFile: String = try Path(path).read()
        let config = try YAMLDecoder().decode(Config.self, from: configFile)

        return config
    }
}
