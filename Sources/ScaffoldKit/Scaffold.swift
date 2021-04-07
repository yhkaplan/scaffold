import ArgumentParser

public struct Scaffold: ParsableCommand {

    // MARK: - Flags

    @Flag(name: .shortAndLong, help: "Print the output without writing the file(s) to disk. Default is false.")
    var dryRun: Bool = false

    // MARK: - Options

    @Option(name: .shortAndLong, help: "Path to output folder(s).")
    var outputPath: String?

    @Option(
        name: .shortAndLong,
        help: "Single template or comma-separated list of templates to generate from the config file"
    )
    var template: String?

    @Option(name: .shortAndLong, help: "Group from config file with list of templates")
    var group: String?

    @Option(help: "Path to config file. Default is .scaffold.yml")
    var configFilePath: String?

    @Option(name: .shortAndLong, help: "Value to pass to the name variable in the stencil template")
    var name: String?

    @Option(name: .shortAndLong, help: "String with context values to pass to template (overrides name).")
    var context: String?

    // MARK: - Methods

    public init() {}

    public func run() throws {
        let command = Command(
            dryRun: dryRun,
            outputPath: outputPath,
            template: template,
            group: group,
            configFilePath: configFilePath,
            name: name,
            context: context
        )
        try Runner().run(command: command)
    }
}

// MARK: - Scaffold.Runner

extension Scaffold {

    struct Runner {
        let loadConfig: (String) throws -> ScaffoldConfig
        let loadContextFile: (String) throws -> [String: Any]
        let writeFile: (RenderedTemplateFile) throws -> Void
        let parseContextArgument: (String) throws -> [String: Any]
        let _renderTemplate: (String, String, [String: Any]) throws -> String

        func run(command: Command) throws {
            let renderContext = try makeContext(
                context: command.context,
                name: command.name
            )
            // `name` must exist in either the --name option, --context option, or --context-file-path
            guard let name = command.name ?? renderContext["name"] as? String else { throw ScaffoldError.noName }

            let templateNames = makeTemplateNames(template: command.template)
            let groupName = command.group
            if groupName == nil && templateNames.isEmpty { throw ScaffoldError.noTemplates }
            if groupName != nil && !templateNames.isEmpty { throw ScaffoldError.templatesAndGroups }

            let configFilePath = command.configFilePath ?? ".scaffold.yml"
            let config = try loadConfig(configFilePath)

            print("🏭 Rendering templates...")

            // When group is invoked
            if let groupConfig = config.groups.first(where: { $0.name == groupName }) {
                for templateName in groupConfig.templateNames {
                    guard let templateConfig = config.templates.first(where: { $0.name == templateName }) else {
                        throw ScaffoldError.templateNotFound
                    }
                    let template = try renderTemplate(
                        filePath: templateConfig.templatePath,
                        templateName: templateName,
                        context: renderContext
                    )

                    if command.dryRun {
                        print(template)

                    } else {
                        guard
                            let outputPath = command.outputPath ?? templateConfig.outputPath ?? groupConfig.outputPath
                        else { throw ScaffoldError.noOutputPath }

                        let renderedTemplateFile = RenderedTemplateFile(
                            fileContents: template,
                            outputPath: outputPath,
                            fileName: templateConfig.fileName,
                            name: name
                        )
                        try writeFile(renderedTemplateFile)
                    }
                }

            // When specific template(s) are invoked
            } else {
                for templateName in templateNames {
                    guard let templateConfig = config.templates.first(where: { $0.name == templateName }) else {
                        throw ScaffoldError.templateNotFound
                    }
                    let template = try renderTemplate(
                        filePath: templateConfig.templatePath,
                        templateName: templateName,
                        context: renderContext
                    )

                    if command.dryRun {
                        print(template)

                    } else {
                        guard let outputPath = command.outputPath ?? templateConfig.outputPath else {
                            throw ScaffoldError.noOutputPath
                        }

                        let renderedTemplateFile = RenderedTemplateFile(
                            fileContents: template,
                            outputPath: outputPath,
                            fileName: templateConfig.fileName,
                            name: name
                        )
                        try writeFile(renderedTemplateFile)
                    }
                }
            }

            print("✅ Complete")
        }
    }
}

extension Scaffold.Runner {
    init() {
        self.loadConfig = ConfigLoader.loadConfig
        self.loadContextFile = ContextLoader.loadContextFile
        self.writeFile = FileWriter.writeFile
        self.parseContextArgument = ContextParser.parseContextArgument
        _renderTemplate = TemplateRenderer.renderTemplate
    }

    private func renderTemplate(filePath: String, templateName: String, context: [String: Any]) throws -> String {
        try _renderTemplate(filePath, templateName, context)
    }

    private func makeContext(context: String?, name: String?) throws -> [String: Any] {
        let contextFromFlag = try context.flatMap(parseContextArgument)
        let contextFromName: [String: Any]? = name.flatMap { name in ["name": name] }

        return contextFromFlag ?? contextFromName ?? [:]
    }

    private func makeTemplateNames(template: String?) -> [String] {
        return template?
            .split(separator: ",")
            .map(String.init)
            ?? []
    }
}

// MARK: - Scaffold.Command

extension Scaffold {

    struct Command {
        let dryRun: Bool
        let outputPath: String?
        let template: String?
        let group: String?
        let configFilePath: String?
        let name: String?
        let context: String?
    }

}
