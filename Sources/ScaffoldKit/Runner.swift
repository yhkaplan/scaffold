/// Internal struct that abstracts actually running the program from CLI input so
/// dependency injection becomes easy and the program's logic is testable.
/// Note: - I also attempted fooling about with a different structure for ParsableCommand, but
/// much of that relies on Reflection and other run-time magic.
struct Runner {
    let loadConfig: (String) throws -> ScaffoldConfig
    let loadContextFile: (String) throws -> [String: Any]
    let writeFile: (RenderedTemplateFile) throws -> Void
    let parseContextArgument: (String) throws -> [String: Any]
    let _renderTemplate: (String, String, [String: Any]) throws -> String
}

// MARK: - Internal

extension Runner {

    init() {
        self.loadConfig = ConfigLoader.loadConfig
        self.loadContextFile = ContextLoader.loadContextFile
        self.writeFile = FileWriter.writeFile
        self.parseContextArgument = ContextParser.parseContextArgument
        _renderTemplate = TemplateRenderer.renderTemplate
    }

    func run(command: Command) throws {
        let renderContext = try makeContext(
            contextFilePath: command.contextFilePath,
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

// MARK: - Private

private extension Runner {

    func renderTemplate(filePath: String, templateName: String, context: [String: Any]) throws -> String {
        try _renderTemplate(filePath, templateName, context)
    }

    func makeContext(contextFilePath: String?, context: String?, name: String?) throws -> [String: Any] {
        let contextFromFile = try contextFilePath.flatMap(loadContextFile)
        let contextFromFlag = try context.flatMap(parseContextArgument)
        let contextFromName: [String: Any]? = name.flatMap { name in ["name": name] }

        return contextFromFile ?? contextFromFlag ?? contextFromName ?? [:]
    }

    func makeTemplateNames(template: String?) -> [String] {
        return template?
            .split(separator: ",")
            .map(String.init)
            ?? []
    }

}
