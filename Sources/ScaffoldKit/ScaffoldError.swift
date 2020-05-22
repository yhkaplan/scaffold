import Foundation

public enum ScaffoldError: String, LocalizedError {
    case noTemplates = "No templates or groups specified!"
    case templatesAndGroups = "Cannot specify both templates and groups!"
    case noOutputPath = "No output path specified!"
    case noFileName = "No output fileName specified!"
    case noName = "Name not specified in --name or --context!"
    case templateNotFound = "Template not found!"

    public var errorDescription: String? { rawValue }
}
