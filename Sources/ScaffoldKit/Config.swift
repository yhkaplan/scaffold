import Yams
import Foundation

struct TemplateConfig {
    let name, templatePath, fileName: String
    let outputPath: String?
}

extension TemplateConfig: Decodable {
    enum CodingKeys: String, CodingKey {
        case name, templatePath, outputPath, fileName
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        templatePath = try c.decode(String.self, forKey: .templatePath)
        fileName = try c.decode(String.self, forKey: .fileName)
        outputPath = try c.decodeIfPresent(String.self, forKey: .outputPath)
    }
}

struct TemplateGroupConfig {
    let name: String
    let templateNames: [String]
    /// Overrides template output path // TODO: make it so the template overrides this instead
    let outputPath: String?
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
    let templates: [TemplateConfig]
    let groups: [TemplateGroupConfig]
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
