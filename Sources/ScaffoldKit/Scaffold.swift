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

    @Option(
        name: [.long, .customShort("C")],
        help: "Path to JSON file with context values to pass to template (overrides name)"
    )
    var contextFilePath: String?

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
            context: context,
            contextFilePath: contextFilePath
        )
        try Runner().run(command: command)
    }
}
