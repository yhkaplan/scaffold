//
//  Scaffold.swift
//  ArgumentParser
//
//  Created by josh on 2020/05/04.
//

import Stencil
import StencilSwiftKit
import ArgumentParser
import Foundation
import PathKit
import Yams

// TODO: break up into cleaner units, importing on ArgumentParser
public struct Scaffold: ParsableCommand {

    // MARK: - Types

    public enum ScaffoldError: String, LocalizedError {
        case noTemplates = "No templates found or specified!"
        public var errorDescription: String? { rawValue }
    }

    // MARK: - Flags

    @Flag(help: "Print the output without writing the file(s) to disk. Default is false.")
    var dryRun: Bool // TODO: can these be private?

    // MARK: - Options

    @Option(help: "Path to specific template or folder of templates. Default is ./Templates/")
    var filePath: String?

    @Option(help: "List of templates to generate from the config file")
    var templates: String? // TODO: can't use array?

    @Option(help: "Path to config file. Default is ./scaffold.yml")
    var configFilePath: String?

    @Option(help: "Path to output folder(s). Default is current directory.")
    var outputPath: String?

    @Option(help: "Value to pass to the name variable in the stencil template")
    var name: String?

    @Option(help: """
    String with context values to pass to template (overrides name). More info here: <link>
    Example: ``
    """)
    var context: String?

    public init() {}

    public func run() throws {
        let filePath = self.filePath ?? "Templates/"
        let templateNames = (self.templates ?? "./")
            .split(separator: ",")
            .map { String($0) + ".stencil" }
        let configFilePath = Path(self.configFilePath ?? "scaffold.yml")
        let outputPath = Path(self.outputPath ?? "./")

        let context: [String: Any]?
        if let name = name {
            context = ["name": name]
            //        } else if let context = self.context { // TODO:
            //            // TODO: parse context w/ parser combinator
        } else {
            context = nil
        }

        let configFile: String = try configFilePath.read()
        let objects = try YAMLDecoder().decode(Config.self, from: configFile)
        dump(objects)

        let path = Path(filePath)
        let loader = FileSystemLoader(paths: [path])
        let env = Environment(loader: loader)

        if templateNames.isEmpty { throw ScaffoldError.noTemplates }

        for templateName in templateNames {
            let template = try env.renderTemplate(name: templateName, context: context)
            if dryRun {
                print(template)
            } else {
                // write to disk
            }
        }
    }

}
