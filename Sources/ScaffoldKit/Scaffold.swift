//
//  Scaffold.swift
//  ArgumentParser
//
//  Created by josh on 2020/05/04.
//

import ArgumentParser

public struct Scaffold: ParsableCommand {

    // MARK: - Flags

    @Flag(help: "Print the output without writing the file(s) to disk. Default is false.")
    var dryRun: Bool

    // MARK: - Options
    @Option(help: "Path to output folder(s).")
    var outputPath: String?

    @Option(help: "List of templates to generate from the config file")
    var templates: String?

    @Option(help: "Group from config file with list of templates")
    var group: String?

    @Option(help: "Path to config file. Default is ./scaffold.yml")
    var configFilePath: String?

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
        let renderContext = TemplateRenderContext(name: name, context: context)
        // `name` must exist in either the --name option or --context option
        guard let name = name ?? renderContext.context?["name"] as? String else { throw ScaffoldError.noName }

        let templateNames = makeTemplateNames()
        let groupName = group
        if groupName == nil && templateNames.isEmpty { throw ScaffoldError.noTemplates }
        if groupName != nil && !templateNames.isEmpty { throw ScaffoldError.templatesAndGroups }

        let configFilePath = self.configFilePath ?? "scaffold.yml"
        let config = try ConfigLoader().loadConfig(at: configFilePath)

        print("🏭 Rendering templates...")

        // When group is invoked
        if let groupConfig = config.groups.first(where: { $0.name == groupName }) {
            for templateName in groupConfig.templateNames {
                guard let templateConfig = config.templates.first(where: { $0.name == templateName }) else {
                    throw ScaffoldError.templateNotFound
                }
                let template = try TemplateRenderer().render(
                    filePath: templateConfig.templatePath,
                    templateName: templateName,
                    context: renderContext
                )

                if dryRun {
                    print(template)

                } else {
                    guard
                        let outputPath = self.outputPath ?? templateConfig.outputPath ?? groupConfig.outputPath
                    else { throw ScaffoldError.noOutputPath }

                    let renderedTemplateFile = RenderedTemplateFile(
                        fileContents: template,
                        outputPath: outputPath,
                        fileName: templateConfig.fileName,
                        name: name
                    )
                    try FileWriter().writeFile(renderedTemplateFile)
                }
            }

        // When specific template(s) are invoked
        } else {
            for templateName in templateNames {
                guard let templateConfig = config.templates.first(where: { $0.name == templateName }) else {
                    throw ScaffoldError.templateNotFound
                }
                let template = try TemplateRenderer().render(
                    filePath: templateConfig.templatePath,
                    templateName: templateName,
                    context: renderContext
                )

                if dryRun {
                    print(template)

                } else {
                    guard
                        let outputPath = self.outputPath ?? templateConfig.outputPath
                    else { throw ScaffoldError.noOutputPath }

                    let renderedTemplateFile = RenderedTemplateFile(
                        fileContents: template,
                        outputPath: outputPath,
                        fileName: templateConfig.fileName,
                        name: name
                    )
                    try FileWriter().writeFile(renderedTemplateFile)
                }
            }
        }

        print("✅ Complete")
    }

    private func makeTemplateNames() -> [String] {
        return templates?
            .split(separator: ",")
            .map(String.init)
            ?? []
    }

}
