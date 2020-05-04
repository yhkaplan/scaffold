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
