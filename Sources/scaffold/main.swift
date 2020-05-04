import Stencil
import StencilSwiftKit
import ArgumentParser
import PathKit
import Yams
import Foundation

struct TemplateConfig {
    var name: String
    var templatePath: String
    var outputPath: String?
}

extension TemplateConfig: Decodable {
    enum CodingKeys: String, CodingKey {
        case name, templatePath, outputPath
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        templatePath = try c.decode(String.self, forKey: .templatePath)
        outputPath = try c.decodeIfPresent(String.self, forKey: .outputPath)
    }
}

struct TemplateGroupConfig {
    var name: String
    var templateNames: [String]
    /// Overrides template output path
    var outputPath: String?
}

extension TemplateGroupConfig: Decodable {
    enum CodingKeys: String, CodingKey {
        case name, templateNames, outputPath
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        templateNames = try c.decode([String].self, forKey: .templateNames)
        outputPath = try c.decodeIfPresent(String.self, forKey: .outputPath)
    }
}

struct Config {
    var templates: [TemplateConfig]
    var groups: [TemplateGroupConfig]
}

extension Config: Decodable {
    enum CodingKeys: String, CodingKey {
        case templates, groups
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        templates = try c.decode([TemplateConfig].self, forKey: .templates)
        groups = try c.decodeIfPresent([TemplateGroupConfig].self, forKey: .groups) ?? []
    }
}

protocol FileWritable {
    func writeFile(_ string: String)
}
struct FileWriter: FileWritable {
    func writeFile(_ string: String) {
        // TODO: just print to stdout for now
        print(string)
    }
}

struct Scaffold: ParsableCommand {

    // MARK: - Types

    enum ScaffoldError: String, LocalizedError {
        case noTemplates = "No templates found or specified!"
        var errorDescription: String? { rawValue }
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

//    private let fileWriter: FileWritable
//
//    init(fileWriter: FileWritable) {
//        self.fileWriter = fileWriter
//    }

    func run() throws {
        let filePath = self.filePath ?? "Templates/"
        let templateNames = (self.templates ?? "./")
            .split(separator: ",")
            .map { String($0) + ".stencil" }
        let configFilePath = Path(self.configFilePath ?? "scaffold.yml")
        let outputPath = self.outputPath ?? "./"

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

        // TODO: use loader field from Environment to load templates: FileSystemLoader
        let path = Path(filePath)
        let loader = FileSystemLoader(paths: [path])
//        let loader = DictionaryLoader(templates: ["template": t])
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

Scaffold.main()
