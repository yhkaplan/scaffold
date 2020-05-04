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
        case noTemplates = "No templates or groups specified!"
        case templatesAndGroups = "Cannot specify both templates and groups!"
        case noOutputPath = "No output path specified!"
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

    @Option(help: "Group from config file with list of templates")
    var group: String?

    @Option(help: "Path to config file. Default is ./scaffold.yml")
    var configFilePath: String?

    @Option(help: "Path to output folder(s).")
    var outputPath: String?

    @Option(help: "Value to pass to the name variable in the stencil template")
    var name: String?

    @Option(help: """
    String with context values to pass to template (overrides name). More info here: <link>
    Example: ``
    """)
    var context: String?

    // MARK: - Methods

    public init() {}

    public func run() throws {
        let templateNames = (templates ?? "./")
            .split(separator: ",")
            .map { String($0) + ".stencil" }
        let configFilePath = Path(self.configFilePath ?? "scaffold.yml")
        let outputPath: Path? = self.outputPath.flatMap(Path.init(_:))
        let groupName = group

        let context: [String: Any]?
        if let name = name {
            context = ["name": name]
//        } else if let context = self.context { // TODO:
//            // TODO: parse context w/ parser combinator
        } else {
            context = nil
        }

        let configFile: String = try configFilePath.read() // TODO: make optional so config file isn't required
        let config = try YAMLDecoder().decode(Config.self, from: configFile)
        dump(config)

        if groupName == nil && templateNames.isEmpty { throw ScaffoldError.noTemplates }
        if groupName != nil && !templateNames.isEmpty { throw ScaffoldError.templatesAndGroups }

        if let groupConfig = config.groups.first(where: { $0.name == groupName }) {
            for templateName in groupConfig.templateNames {
                let templateConfig = config.templates.first(where: { $0.name == templateName })
                let filePath = self.filePath ?? templateConfig?.templatePath ?? "Templates/"
                let path = Path(filePath)
                let loader = FileSystemLoader(paths: [path])
                let env = Environment(loader: loader)

                let template = try env.renderTemplate(name: templateName, context: context)
                if dryRun {
                    print(template)

                } else {
                    let groupConfigOutputPath = groupConfig.outputPath?.replacingOccurrences(of: "{{ name }}", with: name ?? "")

                    guard
                        let outputPath = outputPath
                        ?? groupConfigOutputPath.flatMap(Path.init(_:))
                        ?? templateConfig?.outputPath.flatMap(Path.init(_:))
                    else { throw ScaffoldError.noOutputPath }

                    try FileWriter().writeFile(template, to: outputPath)
                }
            }

        } else {
            for templateName in templateNames {
                let templateConfig = config.templates.first(where: { $0.name == templateName })
                let filePath = self.filePath ?? templateConfig?.templatePath ?? "Templates/"
                let path = Path(filePath)
                let loader = FileSystemLoader(paths: [path])
                let env = Environment(loader: loader)

                let template = try env.renderTemplate(name: templateName, context: context)
                if dryRun {
                    print(template)

                } else {
                    guard let outputPath = outputPath ?? templateConfig?.outputPath.flatMap(Path.init(_:)) else {
                        throw ScaffoldError.noOutputPath
                    }

                    try FileWriter().writeFile(template, to: outputPath)
                }
            }
        }

    }

}