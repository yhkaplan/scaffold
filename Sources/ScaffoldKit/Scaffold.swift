//
//  Scaffold.swift
//  ArgumentParser
//
//  Created by josh on 2020/05/04.
//

// TODO: break out StencilKit logic into TemplateGenerator with TemplateGenerationConfig
import Stencil
import StencilSwiftKit
import PathKit
// until here

import ArgumentParser
//import Foundation

// TODO: break up into cleaner units, importing on ArgumentParser
public struct Scaffold: ParsableCommand {

    // MARK: - Flags

    @Flag(help: "Print the output without writing the file(s) to disk. Default is false.")
    var dryRun: Bool // TODO: can these be private?

    // MARK: - Options

    @Option(help: "Path to specific template or folder of templates. Default is ./Templates/")
    var filePath: String? // TODO: rename to templatePath?

    // TODO: add fileName Option

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
            .map { String($0) } // + ".stencil"
        let configFilePath = self.configFilePath ?? "scaffold.yml"
        let groupName = group

        let context: [String: Any]?
        if let name = name {
            context = ["name": name]
//        } else if let context = self.context { // TODO:
//            // TODO: parse context w/ parser combinator
        } else {
            context = nil
        }

        let config = try ConfigLoader().loadConfig(at: configFilePath)

        if groupName == nil && templateNames.isEmpty { throw ScaffoldError.noTemplates }
        if groupName != nil && !templateNames.isEmpty { throw ScaffoldError.templatesAndGroups }

        // When group is invoked
        if let groupConfig = config.groups.first(where: { $0.name == groupName }) {
            for templateName in groupConfig.templateNames {
                let templateConfig = config.templates.first(where: { $0.name == templateName })
                let filePath = self.filePath ?? templateConfig?.templatePath ?? "Templates/"
                let path = Path(filePath)
                let loader = FileSystemLoader(paths: [path])
                let env = Environment(loader: loader)

                let template = try env.renderTemplate(name: templateName + ".stencil", context: context)
                if dryRun {
                    print(template)

                } else {
                    let groupConfigOutputPath = groupConfig.outputPath?.replacingOccurrences(of: "{{ name }}", with: name ?? "")

                    guard
                        let outputPath = outputPath
                        ?? groupConfigOutputPath
                        ?? templateConfig?.outputPath
                    else { throw ScaffoldError.noOutputPath }

                    guard let fileName = templateConfig?.fileName.replacingOccurrences(of: "{{ name }}", with: name ?? "") else { throw ScaffoldError.noFileName }
                    try FileWriter().writeFile(template, to: outputPath, named: fileName)
                }
            }

        // When specific template is invoked
        } else {
            for templateName in templateNames {
                let templateConfig = config.templates.first(where: { $0.name == templateName })
                let filePath = self.filePath ?? templateConfig?.templatePath ?? "Templates/"
                let path = Path(filePath)
                let loader = FileSystemLoader(paths: [path])
                let env = Environment(loader: loader)

                let template = try env.renderTemplate(name: templateName + ".stencil", context: context)
                if dryRun {
                    print(template)

                } else {
                    guard let outputPath = outputPath ?? templateConfig?.outputPath else {
                        throw ScaffoldError.noOutputPath
                    }

                    guard let fileName = templateConfig?.fileName.replacingOccurrences(of: "{{ name }}", with: name ?? "") else { throw ScaffoldError.noFileName }
                    try FileWriter().writeFile(template, to: outputPath, named: fileName)
                }
            }
        }

    }

}
